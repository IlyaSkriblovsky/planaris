// $Id: PlanSelectionWindow.vala 92 2010-11-24 13:01:19Z mitrandir $

#if FREMANTLE
public class PlanSelectionWindow: Hildon.StackableWindow
#else
public class PlanSelectionWindow: Gtk.VBox
#endif
{
    PlanSet plan_set;
    PlanSetListModel model;


    Gtk.Action action_new;
    Gtk.Action action_delete;
    Gtk.Action action_sync;


    public signal void open_plan(Plan plan);


    public PlanSelectionWindow(PlanSet plan_set)
    {
        this.plan_set = plan_set;

        #if FREMANTLE
            title = _("Plans");
        #endif

        model = new PlanSetListModel(plan_set);

        var view = new Gtk.TreeView.with_model(model);
        view.insert_column_with_attributes(
            -1, _("Plans"),
            new Gtk.CellRendererText(),
            "text", PlanSetListModel.Column.NAME
        );

        #if ! FREMANTLE
            view.headers_visible = true;
        #endif

        view.row_activated.connect(on_row_activated);

        #if FREMANTLE
            var scroll = new Hildon.PannableArea();
        #else
            var scroll = new Gtk.ScrolledWindow(null, null);
        #endif
        scroll.add(view);


        action_new = new Gtk.Action(
            _("New Plan"), _("New Plan"), _("Create new plan"),
            Gtk.STOCK_NEW
        );
        action_new.activate.connect(on_action_new);

        action_delete = new Gtk.Action(
            _("Delete Plan"), _("Delete Plan"), _("Delete selected plan"),
            Gtk.STOCK_DELETE
        );
//        action_delete.activate.connect(on_action_delete);

        #if MAEMO
            action_new.set("stock_id", null);
            action_delete.set("stock_id", null);
            #if FREMANTLE
                action_new.set("icon_name", "general_add");
                action_delete.set("icon_name", "general_delete");
            #else
                action_new.set("icon_name", "gnome-mime-text-plain");
                action_delete.set("icon_name", "qgn_toolb_deletebutton");
            #endif
        #endif



        // ACTIONS

        action_sync = new Gtk.Action(
            _("Sync"), _("Sync"), _("Online synchronization"),
            Gtk.STOCK_REFRESH
        );
        action_sync.activate.connect(sync);
        #if MAEMO
            action_sync.set("stock_id", null);
            #if FREMANTLE
                action_sync.set("icon_name", "general_refresh");
            #else
                action_sync.set("icon_name", "qgn_toolb_gene_refresh");
            #endif
        #endif


        #if FREMANTLE
            var toolbar = new Gtk.Toolbar();
            foreach (var item in create_tool_items())
                toolbar.insert(item, -1);
            add_toolbar(toolbar);
        #endif




        add(scroll);


        set_size_request(200, 100);



        // SIGNALS

        #if FREMANTLE
            open_plan.connect(fremantle_open_plan);
        #endif
    }


    public List<Gtk.ToolItem> create_tool_items()
    {
        var list = new List<Gtk.ToolItem>();
        list.append(action_new.create_tool_item() as Gtk.ToolItem);
        list.append(action_sync.create_tool_item() as Gtk.ToolItem);

        return list;
    }


    void on_action_new()
    {
        var dialog = new Gtk.Dialog();
        dialog.set_transient_for(get_toplevel() as Gtk.Window);
        dialog.title = _("New Plan");
        dialog.add_button(Gtk.STOCK_OK, Gtk.ResponseType.OK);
        dialog.add_button(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL);
        dialog.set_default_response(Gtk.ResponseType.OK);

        #if FREMANTLE
            var entry = new Hildon.Entry(Hildon.SizeType.AUTO_WIDTH | Hildon.SizeType.FINGER_HEIGHT);
            var label = new Hildon.Caption((Gtk.SizeGroup)null, _("Plan name"), entry, (Gtk.Widget)null, Hildon.CaptionStatus.OPTIONAL);
        #else
            var entry = new Gtk.Entry();
            var label = GtkUtil.make_hbox(
                new Gtk.Label(_("Plan name") + ": "), false, false,
                entry, true, true
            );
        #endif

        entry.set_activates_default(true);

        dialog.vbox.add(label);
        dialog.vbox.show_all();

        if (dialog.run() == Gtk.ResponseType.OK)
        {
            var plan = new Plan(0, entry.text, null, null);

            plan_set.add_plan(plan);
        }

        dialog.destroy();
    }


    void on_row_activated(Gtk.TreePath path)
    {
        var plan = model.plan_from_path(path);

        open_plan(plan);
    }


    #if FREMANTLE
    void fremantle_open_plan(Plan plan)
    {
        var plan_widget = new PlanWidget(plan);
        plan_widget.show_all();
    }
    #endif



    void sync()
    {
        show_login_dialog_if_needed();

        if (plan_set.login.length > 0)
        {
            try
            {
                var sync = new Sync();
                sync.sync_with_progressbar(get_toplevel() as Gtk.Window, plan_set);
            }
            catch (SyncError e)
            {
                GtkUtil.error_message(
                    get_toplevel() as Gtk.Window,
                    _("Cannot sync tasks: %s").printf(e.message)
                );
            }
        }
    }



    void show_login_dialog_if_needed()
    {
        if (plan_set.login.length == 0)
        {
            var login_dialog = new LoginDialog(get_toplevel() as Gtk.Window);
            if (login_dialog.run() == Gtk.ResponseType.OK)
            {
                plan_set.login = login_dialog.login;
                plan_set.password = login_dialog.password;
            }

            login_dialog.destroy();
        }
    }
}
