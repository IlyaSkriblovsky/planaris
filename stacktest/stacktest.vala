class StackTest: Hildon.StackableWindow
{
    int n;

    public StackTest(int n = 1)
    {
        this.n = n;
        var btn = new Gtk.Button.with_label("Window %d".printf(n));
        add(btn);
        btn.clicked.connect(on_button);
    }

    ~StackTest()
    {
        stdout.printf("~ %d\n", n);
    }

    void on_button()
    {
        new StackTest(n+1).show_all();
    }
}


public void main(string[] args)
{
    Gtk.init(ref args);

    Hildon.init();

    var window = new StackTest();

    window.destroy.connect(Gtk.main_quit);
    window.show_all();

    Gtk.main();
}
