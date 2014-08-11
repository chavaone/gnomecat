/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of GNOMECAT
 *
 * Copyright (C) 2013 - Marcos Chavarría Teijeiro
 *
 * GNOMECAT is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * GNOMECAT is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with GNOMECAT. If not, see <http://www.gnu.org/licenses/>.
 */

namespace GNOMECAT.UI
{
    /**
     * Widget that dislays the strings to be translated.
     *  This widget can be dockable.
     */
    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/messagelist.ui")]
    public class MessageListWidget : Gtk.Box
    {
        [GtkChild]
        public Gtk.TreeView messages;
        [GtkChild]
        private Gtk.ScrolledWindow scrolled_window;
        [GtkChild]
        public Gtk.TreeSelection selection;

        public signal void message_selected (Message m);

        private uint number_of_msgs;

        private GNOMECAT.File? _file;
        public GNOMECAT.File? file
        {
            get
            {
                return _file;
            }
            set
            {
                if (_file == value)
                    return;

                Gee.ArrayList<GNOMECAT.Message> msgs = value.messages;

                number_of_msgs = 0;

                Gtk.ListStore list_store = new Gtk.ListStore (1, typeof (GNOMECAT.Message));

                messages.model = list_store;
                Gtk.TreeIter iter;

                foreach (GNOMECAT.Message m in msgs)
                {
                    number_of_msgs++;
                    list_store.append (out iter);
                    list_store.set (iter, 0, m, -1);
                }

                GNOMECAT.UI.CellRendererMessage cell = new GNOMECAT.UI.CellRendererMessage ();
                messages.insert_column_with_attributes (0, null, cell, "message", 0);

                selection.select_path (new Gtk.TreePath.from_indices (0));
            }
        }

        public MessageListWidget.with_file (GNOMECAT.File f)
        {
            this ();
            this.file = f;
        }

        public void select (GNOMECAT.SelectLevel level,
            GNOMECAT.MessageFragment? fragment)
        {
            assert (fragment != null && fragment.message != null);

            Gtk.TreePath path = get_path_by_message (fragment.message);
            if (path == null)
                return;

            selection.select_path (path);
        }

        public void deselect (GNOMECAT.SelectLevel level,
            GNOMECAT.MessageFragment? fragment)
        {}


        public Gtk.TreePath? get_path_by_message (GNOMECAT.Message msg)
        {
            Gtk.TreeIter iter;
            GNOMECAT.Message curr_msg;

            messages.model.get_iter_first (out iter);

            do {

                messages.model.get (iter, 0, out curr_msg);
                if (curr_msg == msg)
                {
                    return messages.model.get_path (iter);
                }

            } while (messages.model.iter_next (ref iter));

            return null;
        }


        [GtkCallback]
        private void on_selection_changed ()
        {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            GNOMECAT.Message msg;

            if (selection.get_selected (out model, out iter))
            {
                model.get (iter, 0, out msg);

                message_selected (msg);

                update_scroll (model.get_path (iter));
            }
        }


        private void update_scroll (Gtk.TreePath path)
        {
            int index = path.get_indices () [0];

            Gtk.Adjustment adj = scrolled_window.vadjustment;

            double new_value = ((adj.upper - adj.lower) / number_of_msgs) * index;

            if (new_value < adj.value || new_value > adj.value + adj.page_size)
                adj.value = new_value;
        }
    }


    public class CellRendererMessage : Gtk.CellRenderer
    {

        private GLib.Settings settings;

        public GNOMECAT.Message message {get; set;}

        public CellRendererMessage ()
        {
            GLib.Object ();

            settings = new GLib.Settings ("org.gnome.gnomecat.Editor");
        }

        public override void get_size ( Gtk.Widget widget,
                                        Gdk.Rectangle? cell_area,
                                        out int x_offset,
                                        out int y_offset,
                                        out int width,
                                        out int height)
        {
            x_offset = 0;
            y_offset = 0;
            width = 300;
            height = 60;
        }

        public override void render (Cairo.Context ctx,
                                     Gtk.Widget widget,
                                     Gdk.Rectangle background_area,
                                     Gdk.Rectangle cell_area,
                                     Gtk.CellRendererState flags)
        {
            draw_state (ctx, message, cell_area);

            draw_original (ctx, message, cell_area);

            draw_translation (ctx, message, cell_area);

            draw_tips (ctx, message, cell_area);
        }

        private void draw_state (Cairo.Context ctx, GNOMECAT.Message message, Gdk.Rectangle cell_area)
        {
            Gdk.Pixbuf icon = null;
            Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();

            try
            {
                switch (message.state)
                {
                case MessageState.TRANSLATED:
                    icon = icon_theme.load_icon ("emblem-default-symbolic", 16,
                        Gtk.IconLookupFlags.GENERIC_FALLBACK);
                    break;
                case MessageState.UNTRANSLATED:
                    icon = icon_theme.load_icon ("window-close-symbolic", 16,
                        Gtk.IconLookupFlags.GENERIC_FALLBACK);
                    break;
                case MessageState.FUZZY:
                    icon = icon_theme.load_icon ("dialog-question-symbolic", 16,
                        Gtk.IconLookupFlags.GENERIC_FALLBACK);
                    break;
                }
            }
            catch (Error e)
            {
                print ("ERROR!!!\n");
                return;
            }

            Gdk.cairo_rectangle (ctx, {cell_area.x + 5,
                                       cell_area.y + 22,
                                       16,
                                       16});

            Gdk.cairo_set_source_pixbuf (ctx,
                                         icon,
                                         cell_area.x + 5,
                                         cell_area.y + 22);
            ctx.fill ();
        }

        private void draw_original (Cairo.Context ctx, GNOMECAT.Message message, Gdk.Rectangle cell_area)
        {
            ctx.set_source_rgb (0, 0, 0);

            Pango.FontDescription font_desc = Pango.FontDescription.from_string (settings.get_string ("font"));
            font_desc.set_weight (Pango.Weight.ULTRAHEAVY);

            Pango.AttrList attributes_original = new Pango.AttrList ();
            attributes_original.change (new Pango.AttrFontDesc (font_desc));

            Pango.Layout layout_original =  Pango.cairo_create_layout (ctx);
            string orig = message.get_original_singular ();
            layout_original.set_text (orig, orig.length);
            layout_original.set_ellipsize (Pango.EllipsizeMode.END);
            layout_original.set_width ((cell_area.width - 60) * Pango.SCALE);
            layout_original.set_height (20 * Pango.SCALE);
            layout_original.set_attributes (attributes_original);

            ctx.move_to (cell_area.x + 30, cell_area.y + 5);
            Pango.cairo_show_layout (ctx, layout_original);

        }

        private void draw_translation (Cairo.Context ctx, GNOMECAT.Message message, Gdk.Rectangle cell_area)
        {
            ctx.set_source_rgb (0, 0, 0);

            Pango.FontDescription font_desc = Pango.FontDescription.from_string (settings.get_string ("font"));

            Pango.AttrList attributes_translation = new Pango.AttrList ();
            attributes_translation.change (new Pango.AttrFontDesc (font_desc));

            Pango.Layout layout_translation = Pango.cairo_create_layout (ctx);
            string? trans = message.get_translation (0);
            if (trans == null) trans = "";
            layout_translation.set_text (trans, trans.length);
            layout_translation.set_ellipsize (Pango.EllipsizeMode.END);
            layout_translation.set_width ((cell_area.width - 60) * Pango.SCALE);
            layout_translation.set_height (20 * Pango.SCALE);
            layout_translation.set_attributes (attributes_translation);

            ctx.move_to (cell_area.x + 30, cell_area.y + 35);
            Pango.cairo_show_layout (ctx, layout_translation);
        }

        private void draw_tips (Cairo.Context ctx, GNOMECAT.Message message, Gdk.Rectangle cell_area)
        {
            bool has_info_tips = false, has_warning_tips = false, has_error_tips = false;
            Gdk.Pixbuf icon = null;
            Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();

            for (int i = 0; i < message.tips.size && ! (has_error_tips &&
                has_warning_tips && has_info_tips); i++)
            {
                GNOMECAT.MessageTip t = message.tips.get (i);
                switch (t.level)
                {
                case TipLevel.INFO:
                    has_info_tips = true;
                    break;
                case TipLevel.ERROR:
                    has_error_tips = true;
                    break;
                case TipLevel.WARNING:
                    has_warning_tips = true;
                    break;
                }
            }

            if (has_info_tips)
            {
                icon = icon_theme.load_icon ("dialog-information-symbolic", 11,
                        Gtk.IconLookupFlags.GENERIC_FALLBACK);

                Gdk.cairo_rectangle (ctx, {cell_area.x + cell_area.width - 15,
                                       cell_area.y + 8,
                                       11,
                                       11});

                Gdk.cairo_set_source_pixbuf (ctx,
                                         icon,
                                         cell_area.x + cell_area.width - 15,
                                         cell_area.y + 8);
                ctx.fill ();
            }

            if (has_warning_tips)
            {
                icon = icon_theme.load_icon ("dialog-warning-symbolic", 11,
                        Gtk.IconLookupFlags.GENERIC_FALLBACK);

                Gdk.cairo_rectangle (ctx, {cell_area.x + cell_area.width - 15,
                                       cell_area.y + 25,
                                       11,
                                       11});

                Gdk.cairo_set_source_pixbuf (ctx,
                                         icon,
                                         cell_area.x + cell_area.width - 15,
                                         cell_area.y + 25);
                ctx.fill ();
            }

            if (has_error_tips)
            {
                icon = icon_theme.load_icon ("dialog-error-symbolic", 11,
                        Gtk.IconLookupFlags.GENERIC_FALLBACK);

                Gdk.cairo_rectangle (ctx, {cell_area.x + cell_area.width - 15,
                                       cell_area.y + 42,
                                       11,
                                       11});

                Gdk.cairo_set_source_pixbuf (ctx,
                                         icon,
                                         cell_area.x + cell_area.width - 15,
                                         cell_area.y + 42);
                ctx.fill ();
            }
        }

    }
}
