void test1()
{
    var curl = new Curl.Easy();
    curl.setopt(Curl.Opt.URL, "http://planaris.skriblovsky.net/post.php");

    Curl.HttpPost* first = null;
    Curl.HttpPost* last = null;
    Curl.HttpPost.formadd(&first, &last,
        Curl.FormOption.COPYNAME, "name",
        Curl.FormOption.FILE, "vtest.vala"
    );
    curl.setopt(Curl.Opt.HTTPPOST, first);


    var res = curl.perform();

    if (res == Curl.Code.OK)
        stdout.printf("ok\n");
    else
        stdout.printf("not ok\n");

    Curl.HttpPost.formfree(first);
}

void test2()
{
    var curl = new Curl.Easy();
    curl.setopt(Curl.Opt.URL, "http://planaris.skriblovsky.net/download.php");

    var f = GLib.FileStream.open("vtmp", "wb");
    curl.setopt(Curl.Opt.WRITEDATA, f);

    var res = curl.perform();
    if (res == Curl.Code.OK)
        stdout.printf("ok\n");
    else
        stdout.printf("not ok\n");
}

public void main(string[] args)
{
    Curl.Global.init(Curl.Global.Flags.DEFAULT);

    test1();
    stdout.printf("=================================\n");
    test2();
}
