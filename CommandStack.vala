// $Id: CommandStack.vala 43 2010-11-13 09:32:38Z mitrandir $

public class CommandStack
{
    private GLib.List<Command> _commands = new GLib.List<Command>();
    public GLib.List<Command> commands
    {
        get { return _commands; }
    }

    private unowned GLib.List<Command> _current = null;
    public Command? current
    {
        get
        {
            if (_current != null)
                return _current.data;
            else
                return null;
        }

        set
        {
            var can_undo_before = can_undo;
            var can_redo_before = can_redo;

            _current = _commands.find(value);

            if (can_undo != can_undo_before) can_undo_toggled();
            if (can_redo != can_redo_before) can_redo_toggled();
        }
    }


    public CommandStack()
    {
    }

    public void add_command(Command command)
    {
        while (_commands.last() != _current)
        {
            var todel = _commands.last().data;
            _commands.delete_link(_commands.last());
            todel.unref(); // Because delete_link does not frees element's data
        }

        _commands.append(command);

        var can_undo_before = can_undo;
        var can_redo_before = can_redo;

        _current = _commands.last();

        if (can_undo != can_undo_before) can_undo_toggled();
        if (can_redo != can_redo_before) can_redo_toggled();
    }

    public void undo()
    {
        var can_undo_before = can_undo;
        var can_redo_before = can_redo;

        if (_current != null)
        {
            _current.data.unapply();
            _current = _current.prev;
        }

        if (can_undo != can_undo_before) can_undo_toggled();
        if (can_redo != can_redo_before) can_redo_toggled();
    }

    public void redo()
    {
        var can_undo_before = can_undo;
        var can_redo_before = can_redo;

        unowned GLib.List<Command> cmd_to_redo = null;
        if (_current != null)
            cmd_to_redo = _current.next;
        else
            cmd_to_redo = _commands.first();

        if (cmd_to_redo != null)
        {
            _current = cmd_to_redo;
            _current.data.apply();
        }

        if (can_undo != can_undo_before) can_undo_toggled();
        if (can_redo != can_redo_before) can_redo_toggled();
    }


    public bool can_undo { get { return _current != null; } }

    public bool can_redo
    {
        get
        {
            return (_current != null && _current.next != null)
                || (_current == null && _commands.length() != 0);
        }
    }

    public signal void can_undo_toggled();
    public signal void can_redo_toggled();
}
