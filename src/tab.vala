/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of valacat
 *
 * Copyright (C) 2013 - Marcos Chavarría Teijeiro
 *
 * valacat is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * valacat is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with valacat. If not, see <http://www.gnu.org/licenses/>.
 */

using Gtk;
using ValaCAT.FileProject;
using ValaCAT.Iterators;
using ValaCAT.Navigator;
using Gee;


namespace ValaCAT.UI
{

    [GtkTemplate (ui ="/info/aquelando/valacat/ui/tablabel.ui")]
    public class TabLabel : Gtk.Box
    {

        [GtkChild]
        public Gtk.Label tab_name;

        private Tab tab;

        public TabLabel (string label_text, Tab tab)
        {
            tab_name.set_text (label_text);
            this.tab = tab;
        }

        [GtkCallback]
        private void on_close ()
        {
            tab.on_close ();
        }
    }

    /**
     * Generic tab.
     */
    [GtkTemplate (ui = "/info/aquelando/valacat/ui/tab.ui")]
    public abstract class Tab : Gtk.Box
    {
        public Widget label {get; protected set;}
        public abstract ValaCAT.FileProject.File? file {get;}
        public abstract ValaCAT.FileProject.Project? project {get;}

        [GtkChild]
        public Gtk.Box left_box;
        [GtkChild]
        public Gtk.Box center_box;
        [GtkChild]
        public Gtk.Box right_box;

        public Tab (string? label)
        {
            this.label = new TabLabel (label == null ? "" : label, this);
        }

        public void on_close ()
        {
            Gtk.Notebook notebook = get_parent () as Gtk.Notebook;
            notebook.remove_page (notebook.page_num (this));
        }
    }


    /**
     *
     */
    public class FileTab : Tab
    {
        public MessageListWidget message_list;
        public ContextPanel message_context;
        public HintPanelWidget hints_panel;


        private unowned ValaCAT.FileProject.File? _file;
        public override ValaCAT.FileProject.File? file
        {
            get
            {
                return this._file;
            }
        }

        public override ValaCAT.FileProject.Project? project
        {
            get
            {
                return this._file != null ? this._file.project : null;
            }
        }

        private ValaCAT.Navigator.FileNavigator navigator_fuzzy;
        private ValaCAT.Navigator.FileNavigator navigator_translated;
        private ValaCAT.Navigator.FileNavigator navigator_untranslated;
        private ValaCAT.Navigator.FileNavigator navigator_all;

        private ArrayList<ChangedMessageSensible> change_messages_sensible;

        public FileTab (ValaCAT.FileProject.File? f)
        {
            base (f.name);
            _file = f;

            change_messages_sensible = new ArrayList<ChangedMessageSensible> ();

            message_list = new MessageListWidget ();
            message_list.file = f;
            message_list.message_selected.connect (on_message_selected);
            center_box.pack_start (message_list, true, true, 0);

            message_context = new ContextPanel ();
            change_messages_sensible.add (message_context);
            right_box.pack_start (message_context, true, true, 0);

            hints_panel = new HintPanelWidget ();
            change_messages_sensible.add (hints_panel);
            right_box.pack_start (hints_panel, true, true, 0);

            navigator_all = new ValaCAT.Navigator.FileNavigator (f, new TransparentFilter<Message> ());
            change_messages_sensible.add (navigator_all);

            navigator_fuzzy = new ValaCAT.Navigator.FileNavigator (f, new FuzzyFilter ());
            change_messages_sensible.add (navigator_fuzzy);

            navigator_translated = new ValaCAT.Navigator.FileNavigator (f, new TranslatedFilter ());
            change_messages_sensible.add (navigator_translated);

            navigator_untranslated = new ValaCAT.Navigator.FileNavigator (f, new UntranslatedFilter ());
            change_messages_sensible.add (navigator_untranslated);

            if (f.messages.size > 0)
            {
                this.message_context.message = f.messages.get (0);
            }

            this._file.file_changed.connect (() => {
                ValaCAT.UI.Window win = this.get_parent ().get_parent (). get_parent () as ValaCAT.UI.Window;
                win.file_changed (this.file);
            });
        }

        public void on_message_selected (Message m)
        {
            foreach (ChangedMessageSensible c in change_messages_sensible)
                c.message = m;
        }

        public void undo ()
        {
            MessageEditorTab tab;
            if ((tab = message_list.get_active_editor_tab ()) != null)
                tab.undo ();
        }

        public void redo ()
        {
            MessageEditorTab tab;
            if ((tab = message_list.get_active_editor_tab ()) != null)
                tab.redo ();
        }

        public void go_next ()
        {
            this.navigator_all.next ();
        }

        public void go_previous ()
        {
            this.navigator_all.previous ();
        }

        public void go_next_fuzzy ()
        {
            this.navigator_fuzzy.next ();
        }

        public void go_previous_fuzzy ()
        {
            this.navigator_fuzzy.previous ();
        }

        public void go_next_translated ()
        {
            this.navigator_translated.next ();
        }

        public void go_previous_translated ()
        {
            this.navigator_translated.previous ();
        }

        public void go_next_untranslated ()
        {
            this.navigator_untranslated.next ();
        }

        public void go_previous_untranslated ()
        {
            this.navigator_untranslated.previous ();
        }

        public void select (ValaCAT.SelectLevel level,
            ValaCAT.FileProject.MessageFragment? fragment)
        {
            message_list.select (level, fragment);
        }

        public void deselect (ValaCAT.SelectLevel level,
            ValaCAT.FileProject.MessageFragment? fragment)
        {
            message_list.deselect (level, fragment);
        }

        private void set_navigators ()
        {

        }
    }


    /**
     *
     */
    public class ProjectTab : Tab
    {
        private FileListWidget file_list;

        public override ValaCAT.FileProject.File? file
        {
            get
            {
                return null;
            }
        }

        private ValaCAT.FileProject.Project? _project;
        public override ValaCAT.FileProject.Project? project
        {
            get
            {
                return this._project;
            }
        }

        public ProjectTab (Project p)
        {
            base ("project_name"); //TODO project.name
            this._project = p;

            file_list = new FileListWidget.with_project (p);

            center_box.pack_start (file_list, true, true, 0);
        }
    }
}

namespace ValaCAT
{
    public interface ChangedMessageSensible : Object
    {
        public abstract Message message {get;set;}
    }
}
