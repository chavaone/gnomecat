

using ValaCAT.FileProject;

namespace ValaCAT
{

    public enum SelectLevel
    {
        FILE,
        ROW,
        PLURAL,
        STRING
    }

    public class SelectInfo : Object
    {
        public MessageFragment fragment {get; private set;}
        public Message message {get {return fragment.message;}}
        public ValaCAT.FileProject.File file {get {return fragment.message.file;}}
        public SelectLevel level {get; private set;}

        public SelectInfo (MessageFragment fragment, SelectLevel level)
        {
            this.fragment = fragment;
            this.level = level;
        }
    }


    public class TextTag : Object
    {

        public Gtk.TextTag tag {get; private set;}
        public int ini_offset {get; private set;}
        public int end_offset {get; private set;}

        public TextTag (Gtk.TextTag tag)
        {
            this.with_range (tag, -1, -1);
        }

        public TextTag.with_range (Gtk.TextTag tag, int ini_offset, int end_offset)
        {
            this.tag = tag;
            this.ini_offset = ini_offset;
            this.end_offset = end_offset;
        }

        public TextTag.from_message_fragment (MessageFragment mf, string tag_name)
        {
            tag = new Gtk.TextTag (tag_name);

            Gdk.RGBA color_background = Gdk.RGBA ();
            color_background.parse ("blue");
            tag.background_rgba = color_background;
            tag.background_set = true;

            Gdk.RGBA color_foreground = Gdk.RGBA ();
            color_foreground.parse ("white");
            tag.foreground_rgba = color_foreground;
            tag.foreground_set = true;

            tag.weight = Pango.Weight.BOLD;
            tag.weight_set = true;
            this.ini_offset = mf.index;
            this.end_offset = mf.index + mf.length;
        }
    }
}