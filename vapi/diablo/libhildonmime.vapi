[CCode (cheader_filename = "hildon-uri.h")]
namespace Hildon {

	[CCode (cprefix = "HILDON_URI_ACTION_")]
	public enum URIActionType {
		NORMAL,
		NEUTRAL,
		FALLBACK
	}

	public errordomain URIError {
		INVALID_URI,
		INVALID_ACTION,
		INVALID_SCHEME,
		NO_DEFAULT_ACTION,
		OPEN_FAILED,
		SAVE_FAILED,
		DBUS_FAILED,
		NO_ACTIONS
	}

	[CCode (cprefix = "hildon_uri_", ref_function = "hildon_uri_action_ref", unref_function = "hildon_uri_action_unref", cheader_filename = "hildon-uri.h")]
	public class URIAction {
		public Hildon.URIActionType get_type ();
		[CCode (cname = "hildon_uri_action_get_name")]
		public unowned string get_name ();
		[CCode (cname = "hildon_uri_action_get_service")]
		public unowned string get_service ();
		[CCode (cname = "hildon_uri_action_get_method")]
		public unowned string get_method ();
		[CCode (cname = "hildon_uri_action_get_translation_domain")]
		public unowned string get_translation_domain ();
		public static GLib.SList<Hildon.URIAction> get_actions (string scheme) throws GLib.Error;
		public static GLib.SList<Hildon.URIAction> get_actions_by_uri (string uri_str, Hildon.URIActionType type) throws GLib.Error;
		public static void free_actions (GLib.SList<Hildon.URIAction> list);
		public static string get_scheme_from_uri (string uri) throws GLib.Error;
		public bool is_default_action () throws GLib.Error;
		[CCode (instance_pos = -2)]
		public bool is_default_action_by_uri (string uri) throws GLib.Error;
		public static Hildon.URIAction get_default_action (string scheme) throws GLib.Error;
		public static Hildon.URIAction get_default_action_by_uri (string uri) throws GLib.Error;
		[CCode (instance_pos = -2)]
		public bool set_default_action (string scheme) throws GLib.Error;
		[CCode (instance_pos = -2)]
		public bool set_default_action_by_uri (string uri_str) throws GLib.Error;
		[CCode (instance_pos = -2)]
		public bool open (string uri) throws GLib.Error;
	}

}

[CCode (cheader_filename = "hildon-mime.h")]
namespace HildonMime {

	public errordomain PatternsError {
		INTERNAL
	}

	GLib.SList<string> patterns_get_for_mime_type (string mime_type) throws GLib.Error;

	public enum Category {
		BOOKMARKS,
		CONTACTS,
		DOCUMENTS,
		EMAILS,
		IMAGES,
		AUDIO,
		VIDEO,
		OTHER,
		ALL
	}

	public HildonMime.Category get_category_for_mime_type (string mime_type);
	public GLib.List<string> get_mime_types_for_category (HildonMime.Category category);
	[CCode (cname = "hildon_mime_types_list_free")]
	public void mime_types_list_free (GLib.List<string> list);

	public int open_file (DBus.RawConnection con, string file);
	public int open_file_list (DBus.RawConnection con, GLib.SList<string> files);
	public int open_file_with_mime_type (DBus.RawConnection con, string file, string mime_type);

	public unowned string get_category_name (HildonMime.Category category);
	public HildonMime.Category get_category_from_name (string name);

	public GLib.List<string> application_get_mime_types (string application_id);
	public void application_mime_types_list_free (GLib.List<string> mime_types);

	[CCode (array_length = -1)]
	string[] get_icon_names (string mime_type, GnomeVFS.FileInfo file_info);
}

