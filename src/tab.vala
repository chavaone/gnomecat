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
    /**
     * Generic tab.
     */
    public abstract class Tab : Gtk.Box
    {
        public Label label {get; protected set;}
        public abstract ValaCAT.FileProject.File? file {get;}
        public abstract ValaCAT.FileProject.Project? project {get;}

        public Tab (string label)
        {
            this.label = new Gtk.Label (label);
        }
    }


    /**
     *
     */
    [GtkTemplate (ui = "/info/aquelando/valacat/ui/filetab.ui")]
    public class FileTab : Tab
    {
        [GtkChild]
        public MessageListWidget message_list;
        [GtkChild]
        public MessageEditorWidget message_editor;
        [GtkChild]
        public ContextPanel message_context;

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

        private ValaCAT.Navigator.Navigator navigator_fuzzy;
        private ValaCAT.Navigator.Navigator navigator_translated;
        private ValaCAT.Navigator.Navigator navigator_untranslated;
        private ValaCAT.Navigator.Navigator navigator_all;

        private ArrayList<ChangedMessageSensible> change_messages_sensible;

        public FileTab (ValaCAT.FileProject.File? f)
        {
            base (f.name);
            _file = f;

            message_list.file = f;
            change_messages_sensible = new ArrayList<ChangedMessageSensible> ();
            change_messages_sensible.add (message_editor);
            change_messages_sensible.add (message_context);
            set_navigators ();
            message_list.message_selected.connect (on_message_selected);

            if (f.messages.size > 0)
            {
                this.message_context.message = f.messages.get (0);
                this.message_editor.message = f.messages.get (0);
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
            if (this.message_editor == null)
                return;
            MessageEditorTab tab = this.message_editor.get_active_tab ();
            tab.undo ();
        }

        public void redo ()
        {
            if (this.message_editor == null)
                return;
            MessageEditorTab tab = this.message_editor.get_active_tab ();
            tab.redo ();
        }

        public void go_next ()
        {
            this.navigator_all.next_item ();
        }

        public void go_previous ()
        {
            this.navigator_all.previous_item ();
        }

        public void go_next_fuzzy ()
        {
            this.navigator_fuzzy.next_item ();
        }

        public void go_previous_fuzzy ()
        {
            this.navigator_fuzzy.previous_item ();
        }

        public void go_next_translated ()
        {
            this.navigator_translated.next_item ();
        }

        public void go_previous_translated ()
        {
            this.navigator_translated.previous_item ();
        }

        public void go_next_untranslated ()
        {
            this.navigator_untranslated.next_item ();
        }

        public void go_previous_untranslated ()
        {
            this.navigator_untranslated.previous_item ();
        }

        private void set_navigators ()
        {
            IteratorFilter<Message> fuzzy_filter = new FuzzyFilter ();
            IteratorFilter<Message> untranslated_filter = new UntranslatedFilter ();
            IteratorFilter<Message> translated_filter = new TranslatedFilter ();

            ArrayList<IteratorFilter<Message>> arr = new ArrayList<IteratorFilter<Message>> ();
            arr.add (fuzzy_filter);
            arr.add (untranslated_filter);
            arr.add (translated_filter);
            IteratorFilter<Message> all_filter = new ORFilter<Message> (arr);

            navigator_all = new ValaCAT.Navigator.Navigator (this, all_filter);
            change_messages_sensible.add (navigator_all);
            navigator_fuzzy = new ValaCAT.Navigator.Navigator (this, fuzzy_filter);
            change_messages_sensible.add (navigator_fuzzy);
            navigator_translated = new ValaCAT.Navigator.Navigator (this, translated_filter);
            change_messages_sensible.add (navigator_translated);
            navigator_untranslated = new ValaCAT.Navigator.Navigator (this, untranslated_filter);
            change_messages_sensible.add (navigator_untranslated);
        }
    }


    /**
     *
     */
    [GtkTemplate (ui = "/info/aquelando/valacat/ui/projecttab.ui")]
    public class ProjectTab : Tab
    {
        [GtkChild]
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
