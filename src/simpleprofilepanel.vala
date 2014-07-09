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

using Gee;

namespace GNOMECAT.UI
{
    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/simpleprofilepanel.ui")]
    public class SimpleProfilePanel : Gtk.Stack, GNOMECAT.UI.Panel
    {

        [GtkChild]
        private Gtk.Entry profile_name_entry;
        public string profile_name
        {
            get
            {
                return profile_name_entry.text;
            }
            set
            {
                profile_name_entry.text = value;
            }
        }

        [GtkChild]
        private Gtk.Entry translator_name_entry;
        public string translator_name
        {
            get
            {
                return translator_name_entry.text;
            }
            set
            {
                translator_name_entry.text = value;
            }
        }

        [GtkChild]
        private Gtk.Entry translator_email_entry;
        public string translator_email
        {
            get
            {
                return translator_email_entry.text;
            }
            set
            {
                translator_email_entry.text = value;
            }
        }

        [GtkChild]
        private Gtk.Entry team_email_entry;
        public string team_email
        {
            get
            {
                return team_email_entry.text;
            }
            set
            {
                team_email_entry.text = value;
            }
        }

        [GtkChild]
        private Gtk.ComboBox encoding_combobox;
        private string _encoding;
        public string encoding
        {
            get
            {
                Gtk.TreeIter iter;

                if (! encoding_combobox.get_active_iter(out iter))
                    return "";

                Value enc_val;
                (encoding_combobox.model as Gtk.ListStore).get_value (iter, 0, out enc_val);
                _encoding = enc_val.get_string ();
                return _encoding;
            }
            set
            {
                if (value == "")
                {
                    encoding_combobox.active = -1;
                    return;
                }

                Gtk.TreeIter iter;

                encoding_combobox.model.get_iter_first(out iter);

                do
                {
                    Value enc_val;
                    (encoding_combobox.model as Gtk.ListStore).get_value (iter, 0, out enc_val);
                    if (enc_val.get_string () == value)
                    {
                        encoding_combobox.set_active_iter (iter);
                        return;
                    }
                } while(encoding_combobox.model.iter_next (ref iter));
                encoding_combobox.active = -1;
            }
        }

        [GtkChild]
        private Gtk.ComboBox language_combobox;
        private Language? _language;
        public Language? language
        {
            get
            {
                Gtk.TreeIter iter;

                if (! language_combobox.get_active_iter(out iter))
                    return null;

                Value lang_code;
                (language_combobox.model as Gtk.ListStore).get_value (iter, 1, out lang_code);
                string code = lang_code.get_string ();

                _language = Language.get_language_by_code (code);
                return _language;
            }
            set
            {
                if (value == null)
                {
                    language_combobox.active = -1;
                    return;
                }

                Gtk.TreeIter iter;

                language_combobox.model.get_iter_first(out iter);

                do
                {
                    Value lang_code;
                    (language_combobox.model as Gtk.ListStore).get_value (iter, 1, out lang_code);
                    string code = lang_code.get_string ();
                    if (code == value.code)
                    {
                        language_combobox.set_active_iter (iter);
                        return;
                    }
                } while(language_combobox.model.iter_next (ref iter));
                language_combobox.active = -1;
            }
        }

        [GtkChild]
        private Gtk.ComboBox plural_form_combobox;
        private PluralForm? _plural_form;
        public PluralForm? plural_form
        {
            get
            {

                Gtk.TreeIter iter;

                if (! plural_form_combobox.get_active_iter(out iter))
                    return null;

                Value exp;
                (plural_form_combobox.model as Gtk.ListStore).get_value (iter, 0, out exp);
                string expression = exp.get_string ();

                _plural_form = PluralForm.get_plural_from_expression (expression);
                return _plural_form;
            }
            set
            {
                if (value == null)
                {
                    plural_form_combobox.active = -1;
                    return;
                }

                Gtk.TreeIter iter;
                plural_form_combobox.model.get_iter_first (out iter);

                do
                {
                    Value exp_val;
                    (plural_form_combobox.model as Gtk.ListStore).get_value (iter, 0, out exp_val);
                    string exp = exp_val.get_string ();
                    if (exp == value.expression)
                    {
                        plural_form_combobox.set_active_iter (iter);
                        return;
                    }
                } while(plural_form_combobox.model.iter_next (ref iter));

                plural_form_combobox.active = -1;
            }
        }

        public virtual GNOMECAT.UI.ToolBarMode toolbarmode
        {
            get
            {
                return GNOMECAT.UI.ToolBarMode.COMPLETE;
            }
        }

        public int window_page {get; set;}

        private GNOMECAT.Profiles.Profile? _profile;
        public GNOMECAT.Profiles.Profile? profile
        {
            get
            {
                return _profile;
            }
            set
            {
                _profile = value;
                if (_profile == null)
                {
                    this.profile_name = "";
                    this.translator_name = "";
                    this.translator_email = "";
                    this.team_email = "";
                    this.encoding = "UTF-8";
                    this.language = null;
                    this.plural_form = null;
                }
                else
                {
                    this.profile_name = _profile.name;
                    this.translator_name = _profile.translator_name;
                    this.translator_email = _profile.translator_email;
                    this.team_email = _profile.team_email;
                    this.encoding = _profile.encoding;
                    this.language = _profile.language;
                    this.plural_form = _profile.plural_form;
                }
            }
        }

        public SimpleProfilePanel ()
        {
            Gtk.TreeIter iter;

            Gtk.CellRendererText cell = new Gtk.CellRendererText();
            language_combobox.pack_start (cell, true);
            language_combobox.add_attribute (cell, "text", 0);
            (language_combobox.model as Gtk.ListStore).set_sort_column_id (0, Gtk.SortType.ASCENDING);

            cell = new Gtk.CellRendererText();
            cell.ellipsize = Pango.EllipsizeMode.END;
            cell.ellipsize_set = true;
            plural_form_combobox.pack_start (cell, true);
            plural_form_combobox.add_attribute (cell, "text", 0);

            cell = new Gtk.CellRendererText();
            encoding_combobox.pack_start (cell, true);
            encoding_combobox.add_attribute (cell, "text", 0);

            foreach (var entry in Language.languages.entries)
            {
                Gtk.ListStore model = language_combobox.model as Gtk.ListStore;
                model.append (out iter);
                model.set_value (iter, 0, entry.value.name);
                model.set_value (iter, 1, entry.value.code);
            }

            foreach (var entry in PluralForm.plural_forms.entries)
            {
                Gtk.ListStore model = plural_form_combobox.model as Gtk.ListStore;
                model.append (out iter);
                model.set_value (iter, 0, entry.value.expression);
            }
        }


        public virtual void on_done (GNOMECAT.UI.Window window)
        {
            if (profile == null)
            {
                GNOMECAT.Profiles.Profile new_prof = new GNOMECAT.Profiles.Profile (this.profile_name,
                    this.translator_name, this.translator_email,
                    this.language, this.plural_form, "8-bits",
                    this.encoding, this.team_email);
                new_prof.save();
                if (GNOMECAT.Application.get_default ().enabled_profile == null)
                    new_prof.set_default();
            }
            else
            {
                profile.name = this.profile_name;
                profile.translator_name = this.translator_name;
                profile.translator_email = this.translator_email;
                profile.language = this.language;
                profile.plural_form = this.plural_form;
                profile.char_set = "8-bits";
                profile.encoding = this.encoding;
                profile.team_email = this.team_email;
            }

            (window.window_panels.get_nth_page(WindowStatus.PREFERENCES) as PreferencesPanel).reload_data ();
            on_back(window);
        }

        public void on_back (GNOMECAT.UI.Window window)
        {
            (GNOMECAT.Application.get_default ().get_active_window () as GNOMECAT.UI.Window)
                .headerbar.done_btn.sensitive = true;
            window.set_panel (WindowStatus.PREFERENCES);
        }

        public virtual void setup_headerbar (GNOMECAT.UI.ToolBar toolbar)
        {
            toolbar.mode = toolbarmode;
            toolbar.stack_switch.stack = this;
            toolbar.stack_switch.visible = true;
            toolbar.done_btn.visible = true;
            toolbar.back_btn.visible = true;
            on_profile_entry_changed (this);
        }

        public void clean_headerbar (GNOMECAT.UI.ToolBar toolbar)
        {
            toolbar.done_btn.sensitive = true;
        }

        public void on_preferences (GNOMECAT.UI.Window window)
        {}

        [GtkCallback]
        public void on_profile_entry_changed (Gtk.Widget w)
        {
            GNOMECAT.UI.Window? window = (GNOMECAT.Application.get_default ().get_active_window () as GNOMECAT.UI.Window);

            if (window != null)
            {
                window.headerbar.done_btn.sensitive =
                    profile_name != "" &&
                    translator_name != "" &&
                    translator_email != "" &&
                    team_email != "" &&
                    encoding != "" &&
                    language != null &&
                    plural_form != null;
            }
        }

        [GtkCallback]
        public void on_language_changed (Gtk.Widget w)
        {
            if (plural_form == null)
            {
                plural_form = language.default_plural_form;
            }

            if (team_email == "")
            {
                team_email = language.default_team_email;
            }
        }
    }
}