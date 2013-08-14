/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

using Gtk;
using ValaCAT.Search;

namespace ValaCAT.UI
{
    [GtkTemplate (ui = "/info/aquelando/valacat/ui/window.ui")]
    public class Window : Gtk.ApplicationWindow
    {
        [GtkChild]
        private Gtk.HeaderBar headerbar;
        [GtkChild]
        private Gtk.SearchEntry search_entry;
        [GtkChild]
        private Gtk.SearchBar search_bar;
        [GtkChild]
        private Gtk.Notebook notebook;
        //[GtkChild]
        private ValaCAT.UI.StatusBar statusbar;
        [GtkChild]
        private Gtk.ToggleButton searchbutton;

        private ValaCAT.UI.SearchDialog search_dialog;
        public ValaCAT.Search.Search active_search {get; set;}

        public signal void file_changed (ValaCAT.FileProject.File? file);
        public signal void project_changed (ValaCAT.FileProject.Project? project);


        private const GLib.ActionEntry[] action_entries = {
            { "edit-undo", on_edit_undo },
            { "edit-redo", on_edit_redo },
            { "search-next", on_search_next },
            { "search-previous", on_search_previous },
            { "edit-save", on_edit_save},
            { "search-advanced", on_search_advanded}
        };


        public Window (ValaCAT.Application.Application app)
        {
            Object(application: app);

            add_action_entries (action_entries, this);

            this.searchbutton.bind_property("active", this.search_bar, "search-mode-enabled", BindingFlags.BIDIRECTIONAL);

            this.file_changed.connect(on_file_changed);
            this.project_changed.connect(on_project_changed);
        }


        public void add_tab (Tab t)
        {
            this.notebook.append_page (t, t.label);
        }

        public Tab get_active_tab ()
        {
            int page_number = this.notebook.get_current_page ();
            return this.notebook.get_nth_page (page_number) as Tab;
        }


        void on_search_advanded ()
        {
            if (this.search_dialog == null)
                this.search_dialog = new SearchDialog(this);
            this.search_dialog.show_all();
        }

        void on_edit_save ()
        {
            Tab t = this.get_active_tab ();
            if (! (t is FileTab))
                return;
            FileTab ft = t as FileTab;
            ft.file.save_file ();
        }

        void on_edit_undo ()
        {
            Tab t = this.get_active_tab ();
            if (! (t is FileTab))
                return;
            FileTab ft = t as FileTab;
            ft.undo ();
        }

        void on_edit_redo ()
        {
            Tab t = this.get_active_tab ();
            if (! (t is FileTab))
                return;
            FileTab ft = t as FileTab;
            ft.redo ();
        }

        void on_search_next ()
        {
            if (this.active_search == null)
                return;
            this.active_search.next_item ();
        }

            void on_search_previous ()
        {
            if (this.active_search == null)
                return;
            this.active_search.previous_item ();
        }

        public void on_file_changed (Window src, ValaCAT.FileProject.File? file)
        {
            if (file == null)
                this.statusbar.hide_file_info ();
            else
                this.statusbar.set_file_info (file.number_of_translated,
                    file.number_of_untranslated,
                    file.number_of_fuzzy);
        }

        public void on_project_changed (Window src, ValaCAT.FileProject.Project? project)
        {
            if (project == null)
                this.statusbar.hide_project_info ();
            /*else
                this.statusbar.set_project_info (project.number_of_translated,
                    project.number_of_untranslated,
                    project.number_of_fuzzy);
            */ //TODO: Add project counters.
        }

        [GtkCallback]
        private void on_switch_page (Gtk.Widget src,
                                    uint page)
        {
            int page_num = int.parse(page.to_string()); //FIXME
            Tab t = this.notebook.get_nth_page (page_num) as Tab;
            this.file_changed (t.file);
            this.project_changed (t.project);
        }

        [GtkCallback]
        private void on_search_changed (Gtk.SearchEntry entry)
        {
            if (this.active_search != null)
                this.active_search.disable();
            if (entry.get_text() == "")
            {
                this.active_search = null;
            }
            else
            {
                this.active_search = new FileSearch (   this.get_active_tab() as FileTab,
                                                        true,
                                                        true,
                                                        true,
                                                        true,
                                                        true,
                                                        false,
                                                        true,
                                                        entry.get_text (),
                                                        "");

                this.active_search.next_item();
            }

        }
    }
}