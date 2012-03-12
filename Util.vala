// $Id: Util.vala 43 2010-11-13 09:32:38Z mitrandir $

namespace Util
{
    public int gen_new_id()
    {
        int id = (int)Random.next_int();
        if (id < 0) id = -id;
        if (id == 0) id = gen_new_id();

        return id;
    }

    public int gen_id_if_zero(int id)
    {
        if (id != 0)
            return id;
        else
            return gen_new_id();
    }
}
