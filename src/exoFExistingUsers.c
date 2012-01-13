/* exoFExistingUsers.c generated by valac 0.12.1, the Vala compiler
 * generated from exoFExistingUsers.vala, do not modify */


#include <glib.h>
#include <glib-object.h>
#include <gtk/gtk.h>
#include <stdlib.h>
#include <string.h>
#include <gee.h>


#define EXOGENESIS_TYPE_FEXISTING_USERS (exogenesis_fexisting_users_get_type ())
#define EXOGENESIS_FEXISTING_USERS(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), EXOGENESIS_TYPE_FEXISTING_USERS, ExogenesisFExistingUsers))
#define EXOGENESIS_FEXISTING_USERS_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), EXOGENESIS_TYPE_FEXISTING_USERS, ExogenesisFExistingUsersClass))
#define EXOGENESIS_IS_FEXISTING_USERS(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), EXOGENESIS_TYPE_FEXISTING_USERS))
#define EXOGENESIS_IS_FEXISTING_USERS_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), EXOGENESIS_TYPE_FEXISTING_USERS))
#define EXOGENESIS_FEXISTING_USERS_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), EXOGENESIS_TYPE_FEXISTING_USERS, ExogenesisFExistingUsersClass))

typedef struct _ExogenesisFExistingUsers ExogenesisFExistingUsers;
typedef struct _ExogenesisFExistingUsersClass ExogenesisFExistingUsersClass;
typedef struct _ExogenesisFExistingUsersPrivate ExogenesisFExistingUsersPrivate;
#define _g_object_unref0(var) ((var == NULL) ? NULL : (var = (g_object_unref (var), NULL)))
#define _g_free0(var) (var = (g_free (var), NULL))
#define _g_error_free0(var) ((var == NULL) ? NULL : (var = (g_error_free (var), NULL)))

#define EXOGENESIS_TYPE_PREVIOUS_OS (exogenesis_previous_os_get_type ())
#define EXOGENESIS_PREVIOUS_OS(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), EXOGENESIS_TYPE_PREVIOUS_OS, ExogenesisPreviousOS))
#define EXOGENESIS_PREVIOUS_OS_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), EXOGENESIS_TYPE_PREVIOUS_OS, ExogenesisPreviousOSClass))
#define EXOGENESIS_IS_PREVIOUS_OS(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), EXOGENESIS_TYPE_PREVIOUS_OS))
#define EXOGENESIS_IS_PREVIOUS_OS_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), EXOGENESIS_TYPE_PREVIOUS_OS))
#define EXOGENESIS_PREVIOUS_OS_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), EXOGENESIS_TYPE_PREVIOUS_OS, ExogenesisPreviousOSClass))

typedef struct _ExogenesisPreviousOS ExogenesisPreviousOS;
typedef struct _ExogenesisPreviousOSClass ExogenesisPreviousOSClass;

#define EXOGENESIS_TYPE_USER_DETAIL (exogenesis_user_detail_get_type ())
#define EXOGENESIS_USER_DETAIL(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), EXOGENESIS_TYPE_USER_DETAIL, ExogenesisUserDetail))
#define EXOGENESIS_USER_DETAIL_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), EXOGENESIS_TYPE_USER_DETAIL, ExogenesisUserDetailClass))
#define EXOGENESIS_IS_USER_DETAIL(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), EXOGENESIS_TYPE_USER_DETAIL))
#define EXOGENESIS_IS_USER_DETAIL_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), EXOGENESIS_TYPE_USER_DETAIL))
#define EXOGENESIS_USER_DETAIL_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), EXOGENESIS_TYPE_USER_DETAIL, ExogenesisUserDetailClass))

typedef struct _ExogenesisUserDetail ExogenesisUserDetail;
typedef struct _ExogenesisUserDetailClass ExogenesisUserDetailClass;
#define _gtk_tree_path_free0(var) ((var == NULL) ? NULL : (var = (gtk_tree_path_free (var), NULL)))

struct _ExogenesisFExistingUsers {
	GtkLayout parent_instance;
	ExogenesisFExistingUsersPrivate * priv;
};

struct _ExogenesisFExistingUsersClass {
	GtkLayoutClass parent_class;
};

struct _ExogenesisFExistingUsersPrivate {
	GtkListStore* _lstUsers;
	GtkCellRendererToggle* tglUserImport;
	GtkCellRendererToggle* tglConfigImport;
	GtkFixed* fxdEU;
	GtkButton* btnCancel;
	GtkButton* btnImport;
	GtkTreeView* tvwUsers;
};


static gpointer exogenesis_fexisting_users_parent_class = NULL;
extern ExogenesisPreviousOS* exogenesis_gPreviousOS;

GType exogenesis_fexisting_users_get_type (void) G_GNUC_CONST;
#define EXOGENESIS_FEXISTING_USERS_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), EXOGENESIS_TYPE_FEXISTING_USERS, ExogenesisFExistingUsersPrivate))
enum  {
	EXOGENESIS_FEXISTING_USERS_DUMMY_PROPERTY
};
ExogenesisFExistingUsers* exogenesis_fexisting_users_new (void);
ExogenesisFExistingUsers* exogenesis_fexisting_users_construct (GType object_type);
static void exogenesis_fexisting_users_Build (ExogenesisFExistingUsers* self);
#define EXOGENESIS_UIPath "/home/steve/1-work/anjuta/exogenesis/src/exogenesis.ui"
void exogenesis_fexisting_users_OnBtnCancel_Click (ExogenesisFExistingUsers* self);
static void _exogenesis_fexisting_users_OnBtnCancel_Click_gtk_button_clicked (GtkButton* _sender, gpointer self);
void exogenesis_fexisting_users_OnBtnImport_Click (ExogenesisFExistingUsers* self);
static void _exogenesis_fexisting_users_OnBtnImport_Click_gtk_button_clicked (GtkButton* _sender, gpointer self);
void exogenesis_fexisting_users_OnFxdEU_Realize (ExogenesisFExistingUsers* self);
static void _exogenesis_fexisting_users_OnFxdEU_Realize_gtk_widget_realize (GtkWidget* _sender, gpointer self);
static void exogenesis_fexisting_users_OnTglUserImport_Toggle (ExogenesisFExistingUsers* self, const gchar* path);
static void _exogenesis_fexisting_users_OnTglUserImport_Toggle_gtk_cell_renderer_toggle_toggled (GtkCellRendererToggle* _sender, const gchar* path, gpointer self);
void exogenesis_fexisting_users_OnTglConfigImport_Toggle (ExogenesisFExistingUsers* self, const gchar* path);
static void _exogenesis_fexisting_users_OnTglConfigImport_Toggle_gtk_cell_renderer_toggle_toggled (GtkCellRendererToggle* _sender, const gchar* path, gpointer self);
gpointer exogenesis_previous_os_ref (gpointer instance);
void exogenesis_previous_os_unref (gpointer instance);
GParamSpec* exogenesis_param_spec_previous_os (const gchar* name, const gchar* nick, const gchar* blurb, GType object_type, GParamFlags flags);
void exogenesis_value_set_previous_os (GValue* value, gpointer v_object);
void exogenesis_value_take_previous_os (GValue* value, gpointer v_object);
gpointer exogenesis_value_get_previous_os (const GValue* value);
GType exogenesis_previous_os_get_type (void) G_GNUC_CONST;
GType exogenesis_user_detail_get_type (void) G_GNUC_CONST;
GeeArrayList* exogenesis_previous_os_get_ExistingUsers (ExogenesisPreviousOS* self);
gint exogenesis_user_detail_get_UserId (ExogenesisUserDetail* self);
const gchar* exogenesis_user_detail_get_Username (ExogenesisUserDetail* self);
const gchar* exogenesis_user_detail_get_HomeFolder (ExogenesisUserDetail* self);
const gchar* exogenesis_user_detail_get_Shell (ExogenesisUserDetail* self);
static void exogenesis_fexisting_users_SetToggle (ExogenesisFExistingUsers* self, const gchar* path, gint col);
static void exogenesis_fexisting_users_finalize (GObject* obj);


ExogenesisFExistingUsers* exogenesis_fexisting_users_construct (GType object_type) {
	ExogenesisFExistingUsers * self = NULL;
	self = (ExogenesisFExistingUsers*) g_object_new (object_type, NULL);
	exogenesis_fexisting_users_Build (self);
	gtk_container_add ((GtkContainer*) self, (GtkWidget*) self->priv->fxdEU);
	return self;
}


ExogenesisFExistingUsers* exogenesis_fexisting_users_new (void) {
	return exogenesis_fexisting_users_construct (EXOGENESIS_TYPE_FEXISTING_USERS);
}


static gpointer _g_object_ref0 (gpointer self) {
	return self ? g_object_ref (self) : NULL;
}


static void _exogenesis_fexisting_users_OnBtnCancel_Click_gtk_button_clicked (GtkButton* _sender, gpointer self) {
	exogenesis_fexisting_users_OnBtnCancel_Click (self);
}


static void _exogenesis_fexisting_users_OnBtnImport_Click_gtk_button_clicked (GtkButton* _sender, gpointer self) {
	exogenesis_fexisting_users_OnBtnImport_Click (self);
}


static void _exogenesis_fexisting_users_OnFxdEU_Realize_gtk_widget_realize (GtkWidget* _sender, gpointer self) {
	exogenesis_fexisting_users_OnFxdEU_Realize (self);
}


static void _exogenesis_fexisting_users_OnTglUserImport_Toggle_gtk_cell_renderer_toggle_toggled (GtkCellRendererToggle* _sender, const gchar* path, gpointer self) {
	exogenesis_fexisting_users_OnTglUserImport_Toggle (self, path);
}


static void _exogenesis_fexisting_users_OnTglConfigImport_Toggle_gtk_cell_renderer_toggle_toggled (GtkCellRendererToggle* _sender, const gchar* path, gpointer self) {
	exogenesis_fexisting_users_OnTglConfigImport_Toggle (self, path);
}


static void exogenesis_fexisting_users_Build (ExogenesisFExistingUsers* self) {
	GtkBuilder* _tmp0_ = NULL;
	GtkBuilder* builder;
	GObject* _tmp1_ = NULL;
	GtkFixed* _tmp2_;
	GObject* _tmp3_ = NULL;
	GtkButton* _tmp4_;
	GObject* _tmp5_ = NULL;
	GtkButton* _tmp6_;
	GObject* _tmp7_ = NULL;
	GtkTreeView* _tmp8_;
	GtkCellRendererText* _tmp9_ = NULL;
	GtkCellRendererText* _tmp10_;
	GtkCellRendererText* _tmp11_ = NULL;
	GtkCellRendererText* _tmp12_;
	GtkCellRendererText* _tmp13_ = NULL;
	GtkCellRendererText* _tmp14_;
	GtkCellRendererText* _tmp15_ = NULL;
	GtkCellRendererText* _tmp16_;
	gint _tmp17_;
	gint _tmp18_;
	GError * _inner_error_ = NULL;
	g_return_if_fail (self != NULL);
	_tmp0_ = gtk_builder_new ();
	builder = _tmp0_;
	gtk_builder_add_from_file (builder, EXOGENESIS_UIPath, &_inner_error_);
	if (_inner_error_ != NULL) {
		_g_object_unref0 (builder);
		goto __catch4_g_error;
	}
	_tmp1_ = gtk_builder_get_object (builder, "fxdExistingUsers");
	_tmp2_ = _g_object_ref0 (GTK_FIXED (_tmp1_));
	_g_object_unref0 (self->priv->fxdEU);
	self->priv->fxdEU = _tmp2_;
	_tmp3_ = gtk_builder_get_object (builder, "btnEUCancel");
	_tmp4_ = _g_object_ref0 (GTK_BUTTON (_tmp3_));
	_g_object_unref0 (self->priv->btnCancel);
	self->priv->btnCancel = _tmp4_;
	_tmp5_ = gtk_builder_get_object (builder, "btnEUImport");
	_tmp6_ = _g_object_ref0 (GTK_BUTTON (_tmp5_));
	_g_object_unref0 (self->priv->btnImport);
	self->priv->btnImport = _tmp6_;
	_tmp7_ = gtk_builder_get_object (builder, "tvwExistingUsers");
	_tmp8_ = _g_object_ref0 (GTK_TREE_VIEW (_tmp7_));
	_g_object_unref0 (self->priv->tvwUsers);
	self->priv->tvwUsers = _tmp8_;
	_tmp9_ = (GtkCellRendererText*) gtk_cell_renderer_text_new ();
	_tmp10_ = g_object_ref_sink (_tmp9_);
	gtk_tree_view_insert_column_with_attributes (self->priv->tvwUsers, -1, "User ID", (GtkCellRenderer*) _tmp10_, "text", 0, NULL, NULL);
	_g_object_unref0 (_tmp10_);
	_tmp11_ = (GtkCellRendererText*) gtk_cell_renderer_text_new ();
	_tmp12_ = g_object_ref_sink (_tmp11_);
	gtk_tree_view_insert_column_with_attributes (self->priv->tvwUsers, -1, "Username", (GtkCellRenderer*) _tmp12_, "text", 1, NULL, NULL);
	_g_object_unref0 (_tmp12_);
	_tmp13_ = (GtkCellRendererText*) gtk_cell_renderer_text_new ();
	_tmp14_ = g_object_ref_sink (_tmp13_);
	gtk_tree_view_insert_column_with_attributes (self->priv->tvwUsers, -1, "Home Folder", (GtkCellRenderer*) _tmp14_, "text", 2, NULL, NULL);
	_g_object_unref0 (_tmp14_);
	_tmp15_ = (GtkCellRendererText*) gtk_cell_renderer_text_new ();
	_tmp16_ = g_object_ref_sink (_tmp15_);
	gtk_tree_view_insert_column_with_attributes (self->priv->tvwUsers, -1, "Shell", (GtkCellRenderer*) _tmp16_, "text", 3, NULL, NULL);
	_g_object_unref0 (_tmp16_);
	gtk_tree_view_insert_column_with_attributes (self->priv->tvwUsers, -1, "Import", (GtkCellRenderer*) self->priv->tglUserImport, "active", 4, NULL, NULL);
	gtk_tree_view_insert_column_with_attributes (self->priv->tvwUsers, -1, "Save Files", (GtkCellRenderer*) self->priv->tglConfigImport, "active", 5, NULL, NULL);
	gtk_tree_view_set_model (self->priv->tvwUsers, (GtkTreeModel*) self->priv->_lstUsers);
	g_signal_connect_object (self->priv->btnCancel, "clicked", (GCallback) _exogenesis_fexisting_users_OnBtnCancel_Click_gtk_button_clicked, self, 0);
	g_signal_connect_object (self->priv->btnImport, "clicked", (GCallback) _exogenesis_fexisting_users_OnBtnImport_Click_gtk_button_clicked, self, 0);
	g_signal_connect_object ((GtkWidget*) self->priv->fxdEU, "realize", (GCallback) _exogenesis_fexisting_users_OnFxdEU_Realize_gtk_widget_realize, self, 0);
	g_signal_connect_object (self->priv->tglUserImport, "toggled", (GCallback) _exogenesis_fexisting_users_OnTglUserImport_Toggle_gtk_cell_renderer_toggle_toggled, self, 0);
	g_signal_connect_object (self->priv->tglConfigImport, "toggled", (GCallback) _exogenesis_fexisting_users_OnTglConfigImport_Toggle_gtk_cell_renderer_toggle_toggled, self, 0);
	g_object_get ((GtkWidget*) self->priv->fxdEU, "width-request", &_tmp17_, NULL);
	g_object_set ((GtkWidget*) self, "width-request", _tmp17_, NULL);
	g_object_get ((GtkWidget*) self->priv->fxdEU, "height-request", &_tmp18_, NULL);
	g_object_set ((GtkWidget*) self, "height-request", _tmp18_, NULL);
	gtk_widget_show_all ((GtkWidget*) self);
	_g_object_unref0 (builder);
	goto __finally4;
	__catch4_g_error:
	{
		GError * err;
		gchar* _tmp19_;
		gchar* _tmp20_;
		GtkMessageDialog* _tmp21_ = NULL;
		GtkMessageDialog* _tmp22_;
		GtkMessageDialog* msg;
		err = _inner_error_;
		_inner_error_ = NULL;
		_tmp19_ = g_strconcat ("Failed to load UI\n", err->message, NULL);
		_tmp20_ = _tmp19_;
		_tmp21_ = (GtkMessageDialog*) gtk_message_dialog_new (NULL, GTK_DIALOG_MODAL, GTK_MESSAGE_ERROR, GTK_BUTTONS_CANCEL, _tmp20_);
		_tmp22_ = g_object_ref_sink (_tmp21_);
		_g_free0 (_tmp20_);
		msg = _tmp22_;
		gtk_dialog_run ((GtkDialog*) msg);
		gtk_main_quit ();
		_g_object_unref0 (msg);
		_g_error_free0 (err);
	}
	__finally4:
	if (_inner_error_ != NULL) {
		g_critical ("file %s: line %d: uncaught error: %s (%s, %d)", __FILE__, __LINE__, _inner_error_->message, g_quark_to_string (_inner_error_->domain), _inner_error_->code);
		g_clear_error (&_inner_error_);
		return;
	}
}


void exogenesis_fexisting_users_OnFxdEU_Realize (ExogenesisFExistingUsers* self) {
	GtkTreeIter iter = {0};
	g_return_if_fail (self != NULL);
	gtk_list_store_clear (self->priv->_lstUsers);
	{
		GeeArrayList* _tmp0_ = NULL;
		GeeArrayList* _tmp1_;
		GeeArrayList* _user_list;
		gint _tmp2_;
		gint _user_size;
		gint _user_index;
		_tmp0_ = exogenesis_previous_os_get_ExistingUsers (exogenesis_gPreviousOS);
		_tmp1_ = _g_object_ref0 (_tmp0_);
		_user_list = _tmp1_;
		_tmp2_ = gee_collection_get_size ((GeeCollection*) _user_list);
		_user_size = _tmp2_;
		_user_index = -1;
		while (TRUE) {
			gpointer _tmp3_ = NULL;
			ExogenesisUserDetail* user;
			GtkTreeIter _tmp4_ = {0};
			gint _tmp5_;
			gchar* _tmp6_ = NULL;
			gchar* _tmp7_;
			const gchar* _tmp8_ = NULL;
			const gchar* _tmp9_ = NULL;
			const gchar* _tmp10_ = NULL;
			_user_index = _user_index + 1;
			if (!(_user_index < _user_size)) {
				break;
			}
			_tmp3_ = gee_abstract_list_get ((GeeAbstractList*) _user_list, _user_index);
			user = (ExogenesisUserDetail*) _tmp3_;
			gtk_list_store_append (self->priv->_lstUsers, &_tmp4_);
			iter = _tmp4_;
			_tmp5_ = exogenesis_user_detail_get_UserId (user);
			_tmp6_ = g_strdup_printf ("%i", _tmp5_);
			_tmp7_ = _tmp6_;
			_tmp8_ = exogenesis_user_detail_get_Username (user);
			_tmp9_ = exogenesis_user_detail_get_HomeFolder (user);
			_tmp10_ = exogenesis_user_detail_get_Shell (user);
			gtk_list_store_set (self->priv->_lstUsers, &iter, 0, _tmp7_, 1, _tmp8_, 2, _tmp9_, 3, _tmp10_, -1, -1);
			_g_free0 (_tmp7_);
			_g_object_unref0 (user);
		}
		_g_object_unref0 (_user_list);
	}
}


static void exogenesis_fexisting_users_OnTglUserImport_Toggle (ExogenesisFExistingUsers* self, const gchar* path) {
	g_return_if_fail (self != NULL);
	g_return_if_fail (path != NULL);
	exogenesis_fexisting_users_SetToggle (self, path, 4);
}


void exogenesis_fexisting_users_OnTglConfigImport_Toggle (ExogenesisFExistingUsers* self, const gchar* path) {
	g_return_if_fail (self != NULL);
	g_return_if_fail (path != NULL);
	exogenesis_fexisting_users_SetToggle (self, path, 5);
}


static void exogenesis_fexisting_users_SetToggle (ExogenesisFExistingUsers* self, const gchar* path, gint col) {
	GtkTreePath* _tmp0_ = NULL;
	GtkTreePath* tpath;
	GtkTreeIter iter = {0};
	GValue active = {0};
	GtkTreeIter _tmp1_ = {0};
	GValue _tmp2_ = {0};
	gboolean _tmp3_;
	g_return_if_fail (self != NULL);
	g_return_if_fail (path != NULL);
	_tmp0_ = gtk_tree_path_new_from_string (path);
	tpath = _tmp0_;
	gtk_tree_model_get_iter ((GtkTreeModel*) self->priv->_lstUsers, &_tmp1_, tpath);
	iter = _tmp1_;
	gtk_tree_model_get_value ((GtkTreeModel*) self->priv->_lstUsers, &iter, col, &_tmp2_);
	G_IS_VALUE (&active) ? (g_value_unset (&active), NULL) : NULL;
	active = _tmp2_;
	_tmp3_ = g_value_get_boolean (&active);
	gtk_list_store_set (self->priv->_lstUsers, &iter, col, !_tmp3_, -1);
	G_IS_VALUE (&active) ? (g_value_unset (&active), NULL) : NULL;
	_gtk_tree_path_free0 (tpath);
}


void exogenesis_fexisting_users_OnBtnCancel_Click (ExogenesisFExistingUsers* self) {
	g_return_if_fail (self != NULL);
}


void exogenesis_fexisting_users_OnBtnImport_Click (ExogenesisFExistingUsers* self) {
	g_return_if_fail (self != NULL);
}


static void exogenesis_fexisting_users_class_init (ExogenesisFExistingUsersClass * klass) {
	exogenesis_fexisting_users_parent_class = g_type_class_peek_parent (klass);
	g_type_class_add_private (klass, sizeof (ExogenesisFExistingUsersPrivate));
	G_OBJECT_CLASS (klass)->finalize = exogenesis_fexisting_users_finalize;
}


static void exogenesis_fexisting_users_instance_init (ExogenesisFExistingUsers * self) {
	GtkListStore* _tmp0_ = NULL;
	GtkCellRendererToggle* _tmp1_ = NULL;
	GtkCellRendererToggle* _tmp2_ = NULL;
	self->priv = EXOGENESIS_FEXISTING_USERS_GET_PRIVATE (self);
	_tmp0_ = gtk_list_store_new (6, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_BOOLEAN, G_TYPE_BOOLEAN);
	self->priv->_lstUsers = _tmp0_;
	_tmp1_ = (GtkCellRendererToggle*) gtk_cell_renderer_toggle_new ();
	self->priv->tglUserImport = g_object_ref_sink (_tmp1_);
	_tmp2_ = (GtkCellRendererToggle*) gtk_cell_renderer_toggle_new ();
	self->priv->tglConfigImport = g_object_ref_sink (_tmp2_);
}


static void exogenesis_fexisting_users_finalize (GObject* obj) {
	ExogenesisFExistingUsers * self;
	self = EXOGENESIS_FEXISTING_USERS (obj);
	_g_object_unref0 (self->priv->_lstUsers);
	_g_object_unref0 (self->priv->tglUserImport);
	_g_object_unref0 (self->priv->tglConfigImport);
	_g_object_unref0 (self->priv->fxdEU);
	_g_object_unref0 (self->priv->btnCancel);
	_g_object_unref0 (self->priv->btnImport);
	_g_object_unref0 (self->priv->tvwUsers);
	G_OBJECT_CLASS (exogenesis_fexisting_users_parent_class)->finalize (obj);
}


GType exogenesis_fexisting_users_get_type (void) {
	static volatile gsize exogenesis_fexisting_users_type_id__volatile = 0;
	if (g_once_init_enter (&exogenesis_fexisting_users_type_id__volatile)) {
		static const GTypeInfo g_define_type_info = { sizeof (ExogenesisFExistingUsersClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) exogenesis_fexisting_users_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (ExogenesisFExistingUsers), 0, (GInstanceInitFunc) exogenesis_fexisting_users_instance_init, NULL };
		GType exogenesis_fexisting_users_type_id;
		exogenesis_fexisting_users_type_id = g_type_register_static (GTK_TYPE_LAYOUT, "ExogenesisFExistingUsers", &g_define_type_info, 0);
		g_once_init_leave (&exogenesis_fexisting_users_type_id__volatile, exogenesis_fexisting_users_type_id);
	}
	return exogenesis_fexisting_users_type_id__volatile;
}


