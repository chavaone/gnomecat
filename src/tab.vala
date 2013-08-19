/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of valacat
 *
 * Copyright (C) 2013 - Marcos Chavarría Teijeiro
 *
 * valacat is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
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

using Gdl;
using Gtk;
using ValaCAT.FileProject;


namespace ValaCAT.UI
{
    /**
     * Generic tab.
     */
    [GtkTemplate (ui = "/info/aquelando/valacat/ui/tab.ui")]
    public abstract class Tab : Box
    {
        public Label label {get; protected set;}
        public abstract ValaCAT.FileProject.File? file {get;}
        public abstract ValaCAT.FileProject.Project? project {get;}

        [GtkChild]
        private Gdl.Dock dock;
        [GtkChild]
        private Gdl.DockBar dockbar;
        private DockLayout layout_manager;

        public Tab ()
        {
            this.dockbar.master = dock;
            this.layout_manager = new DockLayout(dock);
        }

        public void load_layout (string file)
        {
            this.layout_manager.load_from_file(file);
        }

        public void save_layout (string file)
        {
            this.layout_manager.save_to_file(file);
        }

        public void add_item (DockItem item, DockPlacement place)
        {
            this.dock.add_item(item,place);
        }

    }

    public class FileTab : Tab
    {
        public MessageListWidget message_list {get; private set;}
        public MessageEditorWidget message_editor {get; private set;}
        public ContextPanel context_pannel {get; private set;}

        public override ValaCAT.FileProject.File? file {get {return this._file;}}
        public override ValaCAT.FileProject.Project? project {get {return this._file != null ? this._file.project : null;}}

        private ValaCAT.FileProject.File? _file;

        public FileTab (ValaCAT.FileProject.File? f)
        {
            base();
            this.label = new Gtk.Label("f.name"); //TODO f.name;
            this._file = f;
            this.message_list = new MessageListWidget();
            foreach (Message m in f.messages)
            {
                this.message_list.add_message(m);
            }
            this.add_item(this.message_list, DockPlacement.CENTER);

            this.message_editor = new MessageEditorWidget();
            this.message_editor.set_message(f.messages.get(0));
            this.add_item(this.message_editor, DockPlacement.BOTTOM);

            this.context_pannel = new ContextPanel();
            this.context_pannel.set_message(f.messages.get(0));
            this.add_item(this.context_pannel,DockPlacement.RIGHT);

            this.message_list.message_selected.connect ( (source, message) => {
                this.context_pannel.set_message(message);
                this.message_editor.set_message(message);
                });
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
    }

    public class ProjectTab : Tab
    {
        public override ValaCAT.FileProject.File? file {get {return null;}}
        public override ValaCAT.FileProject.Project? project {get {return this._project;}}

        private FileListWidget file_list;

        private ValaCAT.FileProject.Project? _project;

        public ProjectTab (Project p)
        {
            base();
            this.label = new Gtk.Label ("projectname"); //TODO project.name
            this._project = p;

            this.file_list = new FileListWidget.with_project (p);
            this.add_item(this.file_list, DockPlacement.CENTER);
        }


    }
}
