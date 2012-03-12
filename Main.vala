// $Id: Main.vala 91 2010-11-24 12:44:17Z mitrandir $

#if ! FREMANTLE
#if MAEMO
class MainWindow: Hildon.Window
#else
class MainWindow: Gtk.Window
#endif
{
    Gtk.Paned paned;

    PlanSet plan_set;
    PlanSelectionWindow plan_selection_window;

    Gtk.Widget plan_widget = null;
    List<Gtk.ToolItem>? plan_tool_items = null;

    Gtk.Toolbar toolbar;

    bool reopen_plan = false;
    int reopen_plan_id;

    public MainWindow(PlanSet plan_set)
    {
        this.plan_set = plan_set;

        title = _("Planaris");

        this.plan_set.plan_added.connect(on_plan_added);
        this.plan_set.plan_removing.connect(on_plan_removing);

        set_default_size(900, 600);


        toolbar = new Gtk.Toolbar();


        paned = new Gtk.HPaned();

        plan_selection_window = new PlanSelectionWindow(plan_set);
        plan_selection_window.open_plan.connect(on_open_plan);

        foreach (var item in plan_selection_window.create_tool_items())
            toolbar.insert(item, -1);
        toolbar.insert(new Gtk.SeparatorToolItem(), -1);

        paned.add1(plan_selection_window);

        show_empty_right_part();


        #if DIABLO
            add_toolbar(toolbar);
            add(paned);
        #else
            var vbox = new Gtk.VBox(false, 0);
            vbox.pack_start(toolbar, false, false, 0);
            vbox.pack_start(paned, true, true, 0);
            add(vbox);
        #endif
    }


    void remove_right_part()
    {
        if (plan_widget != null)
        {
            paned.remove(plan_widget);

            if (plan_tool_items != null)
            {
                foreach (var item in plan_tool_items)
                    toolbar.remove(item);

                plan_tool_items = null;
            }
        }
    }


    void show_empty_right_part()
    {
        remove_right_part();

        plan_widget = new Gtk.Label(_("Please select plan"));
        paned.add2(plan_widget);
    }


    void on_open_plan(Plan plan)
    {
        reopen_plan = false;

        remove_right_part();

        plan_widget = new PlanWidget(plan);
        paned.add2(plan_widget);
        plan_widget.show_all();

        plan_tool_items = (plan_widget as PlanWidget).create_tool_items();
        foreach (var item in plan_tool_items)
            toolbar.insert(item, -1);
    }

    void on_plan_removing(Plan plan)
    {
        if (plan_widget != null && plan_widget is PlanWidget)
            if ((plan_widget as PlanWidget).plan == plan)
            {
                reopen_plan = true;
                reopen_plan_id = plan.id;
                show_empty_right_part();
            }
    }

    void on_plan_added(Plan plan)
    {
        if (reopen_plan && plan.id == reopen_plan_id)
            on_open_plan(plan);
    }
}
#endif



public int main(string[] args)
{
    Intl.setlocale(LocaleCategory.ALL, "");
    Intl.textdomain("planaris");
    Intl.bindtextdomain("planaris", null);
    Environment.set_application_name(_("Planaris"));
    stdout.printf("%s\n", _("Hello, World!"));

    Gdk.threads_init();
    Gtk.init(ref args);
    #if FREMANTLE
        Hildon.init();
    #endif

    #if MAEMO
        GtkUtil.set_hildon_uri_hook();
    #endif

    var plan_set = new PlanSet();

    try
    {
        plan_set.load();
    }
    catch (LoaderError e)
    {
        stdout.printf(_("Cannot load tasks: %s"), e.message);
    }

    #if FREMANTLE
        var window = new PlanSelectionWindow(plan_set);
    #else
        var window = new MainWindow(plan_set);
    #endif

    #if MAEMO
        Hildon.Program.get_instance().add_window(window);
    #endif

    window.destroy.connect(Gtk.main_quit);

    window.show_all();

    Gdk.threads_enter();
    Gtk.main();
    Gdk.threads_leave();

    try
    {
        plan_set.save();
    }
    catch (SaverError e)
    {
        GtkUtil.error_message(
            window,
            _("Cannot save tasks: %s").printf(e.message)
        );
    }

    return 0;
}
