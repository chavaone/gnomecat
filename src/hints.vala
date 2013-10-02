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

using ValaCAT.FileProject;

namespace ValaCAT.UI
{

	[GtkTemplate (ui = "/info/aquelando/valacat/ui/hintpanelrow.ui")]
	public class HintPanelRow : Gtk.ListBoxRow
	{
		[GtkChild]
		private Gtk.Entry hint;
		[GtkChild]
		private Gtk.Label origin;
	}

	[GtkTemplate (ui = "/info/aquelando/valacat/ui/hintpanelwidget.ui")]
	public class HintPanelWidget : Gtk.Box, ChangedMessageSensible
	{
		[GtkChild]
		private Gtk.ListBox hints_list;

		private Message _message;
		public Message message
		{
			get
			{
				return _message;
			}
			set
			{
				_message = value;
				this.populate_list ();
			}
		}

		private void populate_list ()
		{
			hints_list.foreach ((w) => {
				hints_list.remove (w);
			});

			if (message == null)
				return;
			//TODO:
		}

	}
}

namespace ValaCAT
{
	public class Hint : Object
	{
		public string translation_hint {get; private set;}
		public string origin {get; private set;}
		public double accuracy {get; private set;}

		public Hint (string translation_hint,
					string origin,
					double accuracy)
		{
			this.origin = origin;
			this.translation_hint = translation_hint;
			this.accuracy = accuracy;
		}
	}
}