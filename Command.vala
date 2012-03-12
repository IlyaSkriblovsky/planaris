// $Id: Command.vala 91 2010-11-24 12:44:17Z mitrandir $

public interface Command: GLib.Object
{
    public abstract void apply();
    public abstract void unapply();

    public abstract void print();
}


public class ChangeCommand: GLib.Object, Command
{
    private Task _subject;
    public Task subject { get { return _subject;} }

    private Task _before;
    public Task before { get { return _before;} }

    private Task _after;
    public Task after { get { return _after;} }

    public ChangeCommand(Task subject, Task before, Task after)
    {
        _subject = subject;
        _before = new Task.copy(before);
        _after = new Task.copy(after);

        print();
    }

    public void print()
    {
        stdout.printf("change %s -> %s\n", _before.name, _after.name);
    }

    public void apply()
    {
        _subject.copy_properties_from(_after);
    }

    public void unapply()
    {
        _subject.copy_properties_from(_before);
    }
}


public class AddCommand: GLib.Object, Command
{
    private Task _subject;
    public Task subject { get { return _subject;} }
    private Task _parent;
    public Task parent { get { return _parent;} }

    public AddCommand(Task parent, Task subject)
    {
        _subject = subject;
        _parent = parent;

        print();
    }

    public void print()
    {
        stdout.printf("add %s -> %s\n", _parent.name, _subject.name);
    }

    public void apply()
    {
        _parent.add_child(_subject);
    }

    public void unapply()
    {
        _parent.remove_child(_subject);
    }
}


public class DeleteCommand: GLib.Object, Command
{
    private Task _subject;
    public Task subject { get { return _subject;} }
    private Task _parent;
    public Task parent { get { return _parent;} }

    public DeleteCommand(Task parent, Task subject)
    {
        _subject = subject;
        _parent = parent;

        print();
    }

    public void print()
    {
        stdout.printf("delete %s -> %s\n", _parent.name, _subject.name);
    }

    public void apply()
    {
        _parent.remove_child(_subject);
    }

    public void unapply()
    {
        _parent.add_child(_subject);
    }
}
