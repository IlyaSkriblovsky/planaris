// $Id: TaskCellRenderer.vala 13 2010-11-03 07:41:17Z mitrandir $

class TaskCellRenderer: Gtk.CellRendererText
{
    private int indicator_size;
    private int indicator_spacing;


    private bool _done;
    public bool done {
        get { return _done; }
        set { _done = value; }
    }


    private Task.TaskType _task_type;
    public Task.TaskType task_type {
        get { return _task_type; }
        set { _task_type = value; }
    }


    private double _progress;
    public double progress {
        get { return _progress; }
        set { _progress = value; }
    }

    private bool _show_percent = false;
    public bool show_percent
    {
        get { return _show_percent; }
        set { _show_percent = value; }
    }


    public signal void toggled(string path);
    public signal void fremantle_clicked(Gtk.TreePath path);


    public TaskCellRenderer()
    {
        var toggleRenderer = new Gtk.CellRendererToggle();
        indicator_size = toggleRenderer.indicator_size;
        #if FREMANTLE
            indicator_size = 38;
        #endif

        #if !MAEMO
            Gtk.Widget.get_default_style().get(
                typeof(Gtk.CheckButton), "indicator-spacing",
                out indicator_spacing, null);
        #else
            indicator_spacing = 5;
        #endif

        mode = Gtk.CellRendererMode.ACTIVATABLE;
    }

//    private void print_rect(string name, Gdk.Rectangle rect)
//    {
//        stdout.printf("%s = (%d, %d, %d, %d)\n", name, rect.x, rect.y, rect.width, rect.height);
//    }

    public override void render(
        Gdk.Window window, Gtk.Widget widget,
        Gdk.Rectangle background_area, Gdk.Rectangle cell_area,
        Gdk.Rectangle expose_area, Gtk.CellRendererState flags
    )
    {
        strikethrough = done;
        style = done ? Pango.Style.ITALIC : Pango.Style.NORMAL;

        #if ! DIABLO
            if (done)
                foreground = widget.style.fg[Gtk.StateType.INSENSITIVE].to_string();
            else
                foreground = widget.style.fg[Gtk.StateType.NORMAL].to_string();
        #endif

        if (task_type == Task.TaskType.CHECK)
        {
            Gdk.Rectangle shifted_background_area = background_area;
            Gdk.Rectangle shifted_cell_area = cell_area;
            Gdk.Rectangle shifted_expose_area = expose_area;
            shifted_background_area.x += indicator_size + indicator_spacing;
            shifted_cell_area.x += indicator_size + indicator_spacing;
            shifted_expose_area.x += indicator_size + indicator_spacing;

            base.render(window, widget, shifted_background_area, shifted_cell_area, shifted_expose_area, flags);


            Gtk.paint_check(
                widget.style, window,
                Gtk.StateType.NORMAL,
                done ? Gtk.ShadowType.IN : Gtk.ShadowType.OUT,
                null,
                widget,
                "",
                cell_area.x,
                cell_area.y + (cell_area.height - indicator_size) / 2,
                indicator_size,
                indicator_size
            );
        }
        else if (task_type == Task.TaskType.PROGRESS)
        {
            Gdk.Rectangle pr_rect = Gdk.Rectangle();
            pr_rect.x = cell_area.x;
            #if FREMANTLE
                pr_rect.height = 20;
                pr_rect.width = 50;
            #else
                #if DIABLO
                    pr_rect.height = cell_area.height - 14;
                    pr_rect.width = 30;
                #else
                    pr_rect.height = cell_area.height - 14;
                    pr_rect.width = 20;
                #endif
            #endif
            pr_rect.y = cell_area.y + (cell_area.height - pr_rect.height) / 2;

            Gdk.Rectangle shifted_background_area = background_area;
            Gdk.Rectangle shifted_cell_area = cell_area;
            Gdk.Rectangle shifted_expose_area = expose_area;
            shifted_background_area.x += (int)(1.1 * pr_rect.width);
            shifted_cell_area.x += (int)(1.1 * pr_rect.width);
            shifted_expose_area.x += (int)(1.1 * pr_rect.width);

            base.render(window, widget, shifted_background_area, shifted_cell_area, shifted_expose_area, flags);

            var gc = new Gdk.GC(window);
            gc.set_rgb_fg_color(widget.style.fg[Gtk.StateType.NORMAL]);
            Gdk.draw_rectangle(window, gc, true,
                pr_rect.x,
                pr_rect.y,
                pr_rect.width,
                pr_rect.height
            );

            gc.set_rgb_fg_color(widget.style.bg[Gtk.StateType.NORMAL]);
            Gdk.draw_rectangle(window, gc, true,
                pr_rect.x + widget.style.xthickness,
                pr_rect.y + widget.style.ythickness,
                pr_rect.width - 2 * widget.style.xthickness,
                pr_rect.height - 2 * widget.style.ythickness
            );

            if (progress > 0.0)
            {
                gc.set_rgb_fg_color(widget.style.bg[Gtk.StateType.SELECTED]);
                Gdk.draw_rectangle(window, gc, true,
                    pr_rect.x + widget.style.xthickness,
                    pr_rect.y + widget.style.ythickness,
                    (int)(progress * (pr_rect.width - 2 * widget.style.xthickness)),
                    pr_rect.height - 2 * widget.style.ythickness
                );
            }

            if (show_percent)
            {
                var layout = widget.create_pango_layout("%.0f%%".printf(progress * 100));
                Pango.Rectangle extents;
                layout.get_pixel_extents(null, out extents);

                Gtk.paint_layout(
                    widget.style, window,
                    Gtk.StateType.NORMAL,
                    true,
                    pr_rect,
                    null,
                    "progressbar",
                    pr_rect.x + (pr_rect.width - extents.width) / 2,
                    pr_rect.y + (pr_rect.height - extents.height) / 2,
                    layout
                );
            }
        }
    }

    public override void get_size(Gtk.Widget widget, Gdk.Rectangle? cell_area,
        out int x_offset, out int y_offset,
        out int width, out int height
    )
    {
        int w;
        base.get_size(widget, cell_area, out x_offset, out y_offset, out w, out height);
        width = w + 30;
    }


    public override bool activate(
            Gdk.Event event, Gtk.Widget widget,
            string path,
            Gdk.Rectangle background_area, Gdk.Rectangle cell_area,
            Gtk.CellRendererState flags
        )
    {
        if (event == null) return false;

        int x = (int)(event.button.x -cell_area.x);

        if (task_type == Task.TaskType.CHECK && 0 <= x && x < indicator_size)
        {
            toggled(path);
            return true;
        }
        else
        {
            #if FREMANTLE
                fremantle_clicked(new Gtk.TreePath.from_string(path));
                return true;
            #else
                return false;
            #endif
        }
    }
}
