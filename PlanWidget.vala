// $Id: PlanWidget.vala 91 2010-11-24 12:44:17Z mitrandir $

#if FREMANTLE
public class PlanWidget: Hildon.StackableWindow
#else
public class PlanWidget: Gtk.VBox
#endif
{
    public Plan plan { get; private set; }

    Gtk.TreeView view;

    Gtk.TreeModelFilter model_filter;


    Gtk.Action action_new_task;
    Gtk.Action action_new_toplevel_task;
    Gtk.Action action_undo;
    Gtk.Action action_redo;
    Gtk.ToggleAction action_hide_done;


    public PlanWidget(Plan _plan)
    {
        this.plan = _plan;

        #if FREMANTLE
            title = _("Tasks");
        #endif


        //
        // PLAN CONFIGURATION
        //

        plan.command_stack.can_undo_toggled.connect(update_undo_redo_sensivity);
        plan.command_stack.can_redo_toggled.connect(update_undo_redo_sensivity);


        //
        // TREE VIEW
        //

        model_filter = new Gtk.TreeModelFilter(plan.task_model, null);

        #if ! FREMANTLE
            view = new Gtk.TreeView.with_model(model_filter);
        #else
            view = (Gtk.TreeView)Hildon.gtk_tree_view_new_with_model(Hildon.UIMode.EDIT, model_filter);
            view.get_selection().set_mode(Gtk.SelectionMode.SINGLE);
        #endif

        view.expand_all();

        #if MAEMO
            view.set("show_expanders", true);
            #if FREMANTLE
                Gtk.rc_parse_string(
                      "style \"toolkit\""
                    + "{"
                    + "    GtkTreeView::expander-size = 40"
                    + "    GtkTreeView::expander-spacing = 20"
                    + "}"
                    + "class \"GtkTreeView\" style \"toolkit\""
                );
            #endif
        #endif


        var renderer = new TaskCellRenderer();
        renderer.toggled.connect(on_renderer_toggled);

        view.insert_column_with_attributes(-1, _("Tasks"),
            renderer,
            text: TaskTreeModel.Column.NAME,
            done: TaskTreeModel.Column.DONE,
            task_type: TaskTreeModel.Column.TASK_TYPE,
            progress: TaskTreeModel.Column.PROGRESS
        );

        #if ! FREMANTLE
            view.headers_visible = true;
        #endif

        view.row_activated.connect(on_row_activated);

        #if FREMANTLE
            renderer.fremantle_clicked.connect((path) => {
                Gtk.TreeIter iter1;
                Gtk.TreeIter iter2;
                model_filter.get_iter(out iter1, path);
                view.get_selection().get_selected(null, out iter2);

                if (iter1 == iter2)
                    on_row_activated(path);
            });
        #endif


        #if FREMANTLE
            var scroll = new Hildon.PannableArea();
        #else
            var scroll = new Gtk.ScrolledWindow(null, null);
        #endif

        scroll.add(view);


        //
        // ACTIONS
        //

        action_new_task = new Gtk.Action(
            _("New Task"), _("New Task"), _("Create new subtask of selected task"),
            Gtk.STOCK_ADD
        );
        action_new_task.activate.connect(() => { on_action_new(false); });

        action_new_toplevel_task = new Gtk.Action(
            _("New Toplevel Task"), _("New Toplevel Task"), _("Create new toplevel task"),
            Gtk.STOCK_ADD
        );
        action_new_toplevel_task.activate.connect(() => { on_action_new(true); });

        action_undo = new Gtk.Action(
            _("Undo"), _("Undo"), _("Undo last action"),
            Gtk.STOCK_UNDO
        );
        action_undo.activate.connect(() => { plan.command_stack.undo(); });

        action_redo = new Gtk.Action(
            _("Redo"), _("Redo"), _("Redo canceled action"),
            Gtk.STOCK_REDO
        );
        action_redo.activate.connect(() => { plan.command_stack.redo(); });

        action_hide_done = new Gtk.ToggleAction(
            _("Hide done"), _("Hide done"), _("Hide checked actions and action with 100% progress"),
            Gtk.STOCK_STRIKETHROUGH
        );
        action_hide_done.toggled.connect(on_action_hide_done_toggled);


        #if MAEMO
            action_new_task.set("stock_id", null);
            action_new_toplevel_task.set("stock_id", null);
            action_undo.set("stock_id", null);
            action_redo.set("stock_id", null);
            #if FREMANTLE
                action_new_task.set("icon_name", "general_add");
                action_new_toplevel_task.set("icon_name", "general_add");
                action_undo.set("icon_name", "general_undo");
                action_redo.set("icon_name", "general_redo");
            #else
                action_new_task.set("icon_name", "qgn_indi_gene_plus");
                action_new_toplevel_task.set("icon_name", "qgn_indi_gene_plus");
                action_undo.set("icon_name", "qgn_toolb_sketch_undo");
                action_redo.set("icon_name", "qgn_toolb_sketch_redo");
            #endif
        #endif

        update_undo_redo_sensivity();


        //
        // TOOLBAR
        //


        #if FREMANTLE
            var toolbar = new Gtk.Toolbar();
            foreach (var item in create_tool_items())
                toolbar.insert(item, -1);
            add_toolbar(toolbar);
        #endif

        add(scroll);
    }



    public List<Gtk.ToolItem> create_tool_items()
    {
        var list = new List<Gtk.ToolItem>();
        list.append(action_new_toplevel_task.create_tool_item() as Gtk.ToolItem);
        list.append(action_new_task.create_tool_item() as Gtk.ToolItem);
        list.append(action_undo.create_tool_item() as Gtk.ToolItem);
        list.append(action_redo.create_tool_item() as Gtk.ToolItem);
        list.append(action_hide_done.create_tool_item() as Gtk.ToolItem);

        return list;
    }



    private void on_renderer_toggled(string strpath)
    {
        var task = plan.task_model.task_from_path(
            model_filter.convert_path_to_child_path(
                new Gtk.TreePath.from_string(strpath)
            )
        );
        var backup = new Task.copy(task);
        task.done = ! task.done;

        plan.command_stack.add_command(new ChangeCommand(task, backup, task));
    }


    private void on_row_activated(Gtk.TreePath path)
    {
        var task = plan.task_model.task_from_path(
            model_filter.convert_path_to_child_path(path)
        );

        var backup = new Task.copy(task);

        var dialog = new TaskDialog(get_toplevel() as Gtk.Window, task);

        var response = dialog.run();
        if (response == TaskDialog.Response.DELETE)
        {
            plan.command_stack.add_command(new DeleteCommand(task.parent, task));

            task.parent.remove_child(task);
        }

        if (response == TaskDialog.Response.OK)
        {
            var command = new ChangeCommand(task, backup, task);
            plan.command_stack.add_command(command);
        }

        dialog.destroy();
    }


    private void on_action_new(bool toplevel)
    {
        var task = new Task(0, "");

        var dialog = new TaskDialog(get_toplevel() as Gtk.Window, task, _("New Task"), false);
        if (dialog.run() == TaskDialog.Response.OK)
        {
            Task parent = null;

            if (toplevel || view.get_selection().count_selected_rows() == 0)
                parent = plan.root;
            else
            {
                var path = view.get_selection().get_selected_rows(null).data;
                if (path != null)
                {
                    Gtk.TreeIter iter;
                    plan.task_model.get_iter(
                        out iter,
                        model_filter.convert_path_to_child_path(path)
                    );
                    parent = plan.task_model.task(iter);
                }
                else
                    parent = plan.root;
            }

            if (parent != null)
            {
                parent.add_child(task);

                plan.command_stack.add_command(new AddCommand(parent, task));

                var path = model_filter.convert_child_path_to_path(
                    plan.task_model.task_path(task)
                );
                view.expand_to_path(path);

                if (toplevel)
                    view.get_selection().select_path(path);
            }
        }

        dialog.destroy();
    }


    private void update_undo_redo_sensivity()
    {
        action_undo.set_sensitive(plan.command_stack.can_undo);
        action_redo.set_sensitive(plan.command_stack.can_redo);
    }




    bool filter_hide_done(Gtk.TreeModel model, Gtk.TreeIter iter)
    {
        bool done;
        model.get(iter, TaskTreeModel.Column.DONE, out done);
        return ! done;
    }

    private void on_action_hide_done_toggled()
    {
        model_filter = new Gtk.TreeModelFilter(plan.task_model, null);

        if (action_hide_done.active)
            model_filter.set_visible_func(filter_hide_done);

        view.set_model(model_filter);
        view.expand_all();
    }
}
