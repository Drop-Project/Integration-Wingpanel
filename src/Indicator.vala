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
	private Notify.Notification notification;

	private Gtk.Label display_icon;
	private Gtk.Grid main_grid;
	private Gtk.Grid in_grid;
	private Gtk.Grid out_grid;

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
			main_grid = new Gtk.Grid ();
			main_grid.orientation = Gtk.Orientation.VERTICAL;
			session = new Drop.Session ();

			var in_transmissions = session.get_incoming_transmissions ();
			var out_transmissions = session.get_outgoing_transmissions ();

			foreach (var transmission in in_transmissions) {
				incoming (new Drop.IncomingTransmission (transmission));
			}

			foreach (var transmission in out_transmissions) {
				outgoing (new Drop.OutgoingTransmission (transmission));
			}

			main_grid.remove.connect (() => {
				chech_visibility ();
			});

			session.new_incoming_transmission.connect (incoming);
			session.new_outgoing_transmission.connect (outgoing);

			chech_visibility ();
			setup_notify ();
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
			notification.update ("Incoming File", message, NOTIFICATION_ICON);

			try {
				notification.show ();
			} catch (Error E) {}
		}
	}

	private void incoming (Drop.IncomingTransmission transmission) {
		debug ("Requesting incoming Transmition\n");
		var widget = new Drop.Widgets.IncomingTransmission (transmission);
		widget.margin = 4;

		main_grid.add (widget);
		widget.visible = true;

		if (notification != null) {
			show_notification (widget.label);
		}

		chech_visibility ();
	}

	private void outgoing (Drop.OutgoingTransmission transmission) {
		debug ("Requesting outgoing Transmition\n");
		var widget = new Drop.Widgets.OutgoingTransmission (transmission);
		widget.margin = 4;

		main_grid.add (widget);
		widget.visible = true;

		chech_visibility ();
	}

	private void chech_visibility () {
		if (main_grid.get_children ().length () == 0) visible = false;
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
	// Temporal workarround for Greeter crash
	if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION)
		return null;
	debug ("Activating Keyboard Indicator");
	var indicator = new Drop.Indicator ();
	return indicator;
}
