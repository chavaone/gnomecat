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

using ValaCAT.Profiles;
using Gee;

namespace ValaCAT.UI
{
    [GtkTemplate (ui = "/info/aquelando/valacat/ui/preferencesdialog.ui")]
    public class PreferencesDialog : Gtk.Dialog
    {
        private Settings settings;

        [GtkChild]
        private Gtk.CheckButton highlight_checkbutton;
        [GtkChild]
        private Gtk.CheckButton visible_whitespace_checkbutton;
        [GtkChild]
        private Gtk.CheckButton use_custom_font_checkbutton;
        [GtkChild]
        private Gtk.FontButton editor_font_fontbutton;
        [GtkChild]
        private Gtk.Box editor_font_hbox;
        [GtkChild]
        private Gtk.ComboBoxText changed_state;
        [GtkChild]
        private Gtk.ListBox profiles_list;

        public PreferencesDialog ()
        {
            settings = new Settings ("info.aquelando.valacat.Editor");

            highlight_checkbutton.active = settings.get_boolean ("highlight");
            visible_whitespace_checkbutton.active = settings.get_boolean ("visible-whitespace");
            editor_font_fontbutton.font = settings.get_string ("font");
            editor_font_hbox.sensitive = settings.get_boolean ("custom-font");
            changed_state.active_id = settings.get_string ("message-changed-state");

            settings.bind ("highlight", highlight_checkbutton, "active",  SettingsBindFlags.DEFAULT);
            settings.bind ("visible-whitespace", visible_whitespace_checkbutton, "active",  SettingsBindFlags.DEFAULT);
            settings.bind ("font", editor_font_fontbutton, "font", SettingsBindFlags.DEFAULT);
            settings.bind ("custom-font", use_custom_font_checkbutton, "active", SettingsBindFlags.DEFAULT);
            settings.bind ("custom-font", editor_font_hbox, "sensitive", SettingsBindFlags.DEFAULT);
            settings.bind ("message-changed-state", changed_state, "active_id", SettingsBindFlags.DEFAULT);

            ArrayList<Profile> profs = ValaCAT.Profiles.Profile.get_profiles ();
            foreach (Profile p in profs)
                profiles_list.add (new ProfileRow (p));
        }

        [GtkCallback]
        private void on_create_profile ()
        {
            ProfileDialog prof_dialog = new ProfileDialog ();

            if (prof_dialog.run () == 0)
            {
                profiles_list.add (new ProfileRow (new Profile (prof_dialog.profile_name,
                    prof_dialog.translator_name, prof_dialog.translator_email,
                    prof_dialog.language, prof_dialog.plural_form, "8-bits",
                    prof_dialog.encoding, prof_dialog.team_email)));
            }
            prof_dialog.destroy ();
        }

        [GtkCallback]
        private void on_remove_profile ()
        {
        }
    }


    [GtkTemplate (ui = "/info/aquelando/valacat/ui/profilerow.ui")]
    public class ProfileRow : Gtk.ListBoxRow
    {

        public Profile profile {get; private set;}
        [GtkChild]
        private Gtk.Label profile_name;
        [GtkChild]
        private Gtk.Label language_code;
        [GtkChild]
        private Gtk.Label enabled;

        public string profile_name_entry_text
        {
            get
            {
                return profile_name.get_text ();
            }
            set
            {
                profile_name.set_text (value);
            }
        }

        public string language_code_entry_text
        {
            get
            {
                return language_code.get_text ();
            }
            set
            {
                language_code.set_text (value);
            }
        }

        public ProfileRow (Profile p)
        {
            profile = p;
            profile_name_entry_text = p.name;
            language_code_entry_text = p.language_code;
            enabled.visible = p.enabled;
            this.bind_property ("profile_name_entry_text", profile, "name",
                BindingFlags.BIDIRECTIONAL);
            this.bind_property ("language_code_entry_text", profile, "language_code",
                BindingFlags.BIDIRECTIONAL);
            profile.bind_property ("enabled", enabled, "visible");
        }

        [GtkCallback]
        private void on_edit_profile ()
        {
            ProfileDialog prof_dialog = new ProfileDialog.from_profile (this.profile);

            if (prof_dialog.run () == 0)
            {
                profile.name = prof_dialog.profile_name;
                profile.translator_name = prof_dialog.translator_name;
                profile.translator_email = prof_dialog.translator_email;
                profile.language = prof_dialog.language;
                profile.plural_form = prof_dialog.plural_form;
                profile.char_set = "8-bits";
                profile.encoding = prof_dialog.encoding;
                profile.team_email = prof_dialog.team_email;
            }
            prof_dialog.destroy ();
        }
    }
}