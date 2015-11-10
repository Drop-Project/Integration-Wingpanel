/*-
 * Copyright (c) 2015 Wingpanel Developers (http://launchpad.net/wingpanel)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public class Drop.Indicator : Wingpanel.Indicator {
	private const string NOTIFICATION_ICON = "";

	private Drop.Session session;
	private Drop.Widgets.IncomingTransmissionList in_list;
	private Drop.Widgets.OutgoingTransmissionList out_list;
	private Notify.Notification notification;

	private Gtk.Label display_icon;
	private Gtk.Grid main_grid;

	private bool open = false;

	public Indicator () {
		Object (code_name: "Wingpanel-Indicator-Drop",
				display_name: _("Drop"),
				description:_("The drop indicator"));
	}

	public override Gtk.Widget get_display_widget () {
		if (display_icon == null) {
			display_icon = new Gtk.Label ("D");
		}

		return display_icon;
	}

	public override Gtk.Widget? get_widget () {
		if (main_grid == null) {
			session = new Drop.Session ();

			main_grid = new Gtk.Grid ();
			main_grid.orientation = Gtk.Orientation.VERTICAL;
			in_list = new Drop.Widgets.IncomingTransmissionList (session);
			out_list = new Drop.Widgets.OutgoingTransmissionList (session);

			in_list.new_transmission.connect ((transmission) => {
				show_notification ("New Incoming File");
				chech_visibility ();
			});
			
			out_list.new_transmission.connect ((transmission) => {
				chech_visibility ();
			});
			
			in_list.transmission_removed.connect ((transmission) => {
				chech_visibility ();
			});	
			
			out_list.transmission_removed.connect ((transmission) => {
				chech_visibility ();
			});	

			chech_visibility ();
			setup_notify ();

			main_grid.add (in_list);
			main_grid.add (out_list);
		}

		return main_grid;
	}

	private void setup_notify () {
		if (notification == null) {
			Notify.init ("Drop");
			string summary = "Incoming File";
			string body = "";

			notification = new Notify.Notification (summary, body, NOTIFICATION_ICON);
		}
	}

	private void show_notification (string message) {
		if (!open) {
			this.notification.update ("Drop share", message, NOTIFICATION_ICON);
			try {
				this.notification.show ();
			} catch (Error E) {}
		}
	}

	private void chech_visibility () {
		if (in_list.transmissions == 0 && out_list.transmissions == 0) visible = false;
		else if (!visible) visible = true;
	}

	public override void opened () {
		open = true;
	}

	public override void closed () {
		open = false;
		chech_visibility ();
	}
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
	if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION)
		return null;
	debug ("Activating Keyboard Indicator");
	var indicator = new Drop.Indicator ();
	return indicator;
}
