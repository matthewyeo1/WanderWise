import 'package:flutter_localization/flutter_localization.dart';

const List<MapLocale> LOCALES = [
  MapLocale("en", LocaleData.EN),
  MapLocale("zh", LocaleData.ZH),
  MapLocale("es", LocaleData.ES),
  MapLocale("de", LocaleData.DE),
];

mixin LocaleData {
  static const String menuText = 'Where will you go next?';
  static const String logOut = 'Logout';
  static const String logOutText = 'Are you sure you want to log out?';
  static const String no = 'No';
  static const String yes = 'Yes';
  static const String help = 'Help';
  static const String activity = '        Activity';
  static const String activityTextNothing = 'No action to be taken';
  static String activityTextSomething = 'Friend Requests: %a';
  static const String upcomingEvents = '        Upcoming Events';
  static const String upcomingEventsNothing = 'No upcoming events';
  static String upcomingEventsSomething = 'Scheduled For: %a';
  static const String dismiss = 'Dismiss';
  static const String tripPlanner = 'Trip Planner';
  static const String uploadDocs = 'Upload Docs';
  static const String settings = 'Settings';
  static const String socials = 'Socials';

  static const String trips = 'My Trips';
  static const String addTrip = 'Add New Trip';
  static const String viewEditTrip = 'View/Edit Trip';
  static const String deleteTrip = 'Delete Trip';
  static const String deleteThisTrip = 'Delete this trip?';
  static const String bodyText1 = 'Plan for exciting trips here!';
  static const String mapAppBar = 'Map';

  static const String shareWithFriends = 'Share With Friends';
  static const String shareButton = 'Share';
  static const String noFriends = 'You have no friends to invite';
  static String shared = 'Shared with %a!';
  static const String sharedTitle = 'Itinerary Shared';
  static String sharedMessage = '%a has shared an itinerary with you!';
  
  static const String feedback = 'Please enter your feedback';
  static const String thankFeedback = 'Thank you for your feedback!';
  static const String errorFeedback = "Error submitting feedback";
  static const String feedbackWord = 'Feedback';
  static const String feedbackSentence = 'We value your feedback. Please let us know what you think!';
  static const String feedbackEnter = 'Enter your feedback here';
  static const String submitButton = 'Submit';

  static const String faq = 'Frequently Asked Questions';
  static const String moreAssistance = 'Need More Assistance?';
  static const String sendFeedback = 'Send Feedback';
  static const String q1 = 'How do I reset my password?';
  static const String a1 = 'To reset your password, go to the settings page and click on "Change Password". Follow the instructions provided.';
  static const String q2 = 'What type of documents can be uploaded?';
  static const String a2 = 'WanderWise only allows for .pdf type documents to be uploaded under "Upload Docs".';
  static const String q3 = 'Am I able to view my itineraries and documents offline?'; 
  static const String a3 = 'Unfortunately, the current version of the app does not support offline sync. Stay tuned for future updates!';
  static const String q4 = 'Can I sort my trips/documents?';
  static const String a4 = 'To sort them to your liking, press & drag your trips/documents!';
  static const String emailUs = 'Email Us';
  static const String callUs = 'Call Us';
  static const String feedbackQuestion = 'Have feedback or suggestions?';
  
  static const String title = 'Title';
  static const String startDate = 'Start Date';
  static const String endDate = 'End Date';
  static const String description = 'Description';
  static String datesTrip = 'Start Date: %a \nEnd Date: %a';

  static const String selectFavLocations = 'Choose from Favourite Locations';
  static const String selectFavLocationsText = 'Copy & paste your favourite places to your itinerary!';
  static const String selectFavLocationsCopy = 'Location copied to clipboard!';

  static const String manageLocation = 'Tap to manage this location';
  static const String origin = 'Origin';
  static const String dest = 'Dest.';
  static const String removeMarkerTitle = 'Remove Marker';
  static const String removeMarkerText = 'Do you want to remove this marker?';
  static const String cancel = 'Cancel';
  static const String removeButton = 'Remove';
  static const String addToFavouritesButton = 'Add to Favourites';
  static const String addedToFavouritesSnackBar = 'Added to Favourite Locations!';






  static const Map<String, dynamic> EN = {
    'Where will you go next?': 'Where will you go next?',
    'Logout': 'Logout',
    'Are you sure you want to log out?': 'Are you sure you want to log out?',
    'No': 'No',
    'Yes': 'Yes',
    'Help': 'Help',
    '        Activity': '        Activity',
    'No action to be taken': 'No action to be taken',
    'Friend Requests: %a': 'Friend Requests: %a',
    '        Upcoming Events': '        Upcoming Events',
    'No upcoming events': 'No upcoming events',
    'Scheduled For: %a': 'Scheduled For: %a',
    'Dismiss': 'Dismiss',
    'Trip Planner': 'Trip Planner',
    'Upload Docs': 'Upload Docs',
    'Settings': 'Settings',
    'Socials': 'Socials',
    'My Trips': 'My Trips',
    'Add New Trip': 'Add New Trip',
    'View/Edit Trip': 'View/Edit Trip',
    'Delete Trip': 'Delete Trip',
    'Delete this trip?': 'Delete this trip?',
    'Plan for exciting trips here!': 'Plan for exciting trips here!',
    'Map': 'Map',
    'Share With Friends': 'Share With Friends',
    'Share': 'Share',
    'You have no friends to invite': 'You have no friends to invite',
    'Shared with %a!': 'Shared with %a!',
    'Itinerary Shared': 'Itinerary Shared',
    '%a has shared an itinerary with you!': '%a has shared an itinerary with you!',
    'Please enter your feedback': 'Please enter your feedback',
    'Thank you for your feedback!': 'Thank you for your feedback!',
    'Error submitting feedback': 'Error submitting feedback',
    'Feedback': 'Feedback',
    'We value your feedback. Please let us know what you think!': 'We value your feedback. Please let us know what you think!',
    'Enter your feedback here': 'Enter your feedback here',
    'Submit': 'Submit',
    'Frequently Asked Questions': 'Frequently Asked Questions',
    'Need More Assistance?': 'Need More Assistance?',
    'Send Feedback': 'Send Feedback',
    'How do I reset my password?': 'How do I reset my password?',
    'To reset your password, go to the settings page and click on "Change Password". Follow the instructions provided.': 'To reset your password, go to the settings page and click on "Change Password". Follow the instructions provided.',
    'What type of documents can be uploaded?': 'What type of documents can be uploaded?',
    'WanderWise only allows for .pdf type documents to be uploaded under "Upload Docs".': 'WanderWise only allows for .pdf type documents to be uploaded under "Upload Docs".',
    'Am I able to view my itineraries and documents offline?': 'Am I able to view my itineraries and documents offline?',
    'Unfortunately, the current version of the app does not support offline sync. Stay tuned for future updates!': 'Unfortunately, the current version of the app does not support offline sync. Stay tuned for future updates!',
    'Can I sort my trips/documents?': 'Can I sort my trips/documents?',
    'To sort them to your liking, press & drag your trips/documents!': 'To sort them to your liking, press & drag your trips/documents!',
    'Email Us': 'Email Us',
    'Call Us': 'Call Us',
    'Have feedback or suggestions?': 'Have feedback or suggestions?',
    'Title': 'Title',
    'Start Date': 'Start Date',
    'End Date': 'End Date',
    'Description': 'Description',
    'Start Date: %a \nEnd Date: %a': 'Start Date: %a \nEnd Date: %a',
    'Choose from Favourite Locations': 'Choose from Favourite Locations',
    'Copy & paste your favourite places to your itinerary!': 'Copy & paste your favourite places to your itinerary!',
    'Location copied to clipboard!': 'Location copied to clipboard!',
    'Tap to manage this location': 'Tap to manage this location',
    'Origin': 'Origin',
    'Dest.': 'Dest.',
    'Remove Marker': 'Remove Marker',
  'Do you want to remove this marker?': 'Do you want to remove this marker?',
  'Cancel': 'Cancel',
  'Remove': 'Remove',
  'Add to Favourites': 'Add to Favourites',
  'Added to Favourite Locations!': 'Added to Favourite Locations!',
  
  
  };

  static const Map<String, dynamic> ZH = {
    'Where will you go next?': '你接下来要去哪里?',
    'Logout': '登出',
    'Are you sure you want to log out?': '确定要退出登录吗？',
    'No': '取消',
    'Yes': '确认',
    'Help': '援助',
    '        Activity': '        活动',
    'No action to be taken': '无需采取任何行动',
    'Friend Requests: %a': '好友请求：%a',
    '        Upcoming Events': '        即将发生的事件',
    'No upcoming events': '没有即将发生的事件',
    'Scheduled For: %a': '计划于：%a',
    'Dismiss': '关闭',
    'Trip Planner': '旅行规划',
    'Upload Docs': '上传文件',
    'Settings': '设置',
    'Socials': '社交',
    'My Trips': '度假',
    'Add New Trip': '添加新行程',
    'View/Edit Trip': '查看/编辑行程',
    'Delete Trip': ' 删除行程',
    'Delete this trip?': '删除此行程吗？',
    'Plan for exciting trips here!': ' 在这里计划令人兴奋的旅行！', 
    'Map': '地图',
    'Share With Friends': '与朋友分享',
    'Share': '分享',
    'You have no friends to invite': '你没有朋友可以邀请',
    'Shared with %a!': '与 %a 分享了！',
    'Itinerary Shared': '行程已分享',
    '%a has shared an itinerary with you!': '%a 已经与你分享了一个行程！',
    'Please enter your feedback': '请输入您的反馈意见',
    'Thank you for your feedback!': ' 谢谢您的反馈！',
    'Error submitting feedback': '提交反馈时出错',
    'Feedback': '反馈',
    'We value your feedback. Please let us know what you think!': '我们重视您的反馈。请告诉我们您的想法！',
    'Enter your feedback here': '在这里输入您的反馈',
    'Submit': '提交',
    'Frequently Asked Questions': '常见问题',
    'Need More Assistance?': '需要更多帮助吗？',
    'Send Feedback': '发送反馈',
    'How do I reset my password?': '我如何重置我的密码？',
    'To reset your password, go to the settings page and click on "Change Password". Follow the instructions provided.': '要重置密码，请前往设置页面并点击“更改密码”。按照提供的说明进行操作。',
    'What type of documents can be uploaded?': '可以上传什么类型的文件？',
    'WanderWise only allows for .pdf type documents to be uploaded under "Upload Docs".': 'WanderWise 只允许上传 .pdf 类型的文件，上传请前往“上传文档”。',
    'Am I able to view my itineraries and documents offline?': '我可以离线查看我的行程和文档吗？',
    'Unfortunately, the current version of the app does not support offline sync. Stay tuned for future updates!': '不幸的是，目前版本的应用程序不支持离线同步。敬请关注未来的更新！',
    'Can I sort my trips/documents?': '我可以排序我的旅行/文档吗？',
    'To sort them to your liking, press & drag your trips/documents!': '要按您的喜好排序，请按住并拖动您的旅行/文档！',
    'Email Us': '给我们发邮件',
    'Call Us': '给我们打电话',
    'Have feedback or suggestions?': '有反馈或建议吗？',
    'Title': '标题',
    'Start Date': '开始日期',
    'End Date': '结束日期',
    'Description': '描述',
    'Start Date: %a \nEnd Date: %a': '开始日期: %a \n结束日期: %a',
    'Choose from Favourite Locations': '选择最喜欢的位置',
    'Copy & paste your favourite places to your itinerary!': '复制并粘贴你最喜欢的地方到你的行程中！',
    'Location copied to clipboard!': '位置已复制到剪贴板！',
    'Tap to manage this location': '点击管理此位置',
    'Origin': '起点',
    'Dest.': '目的地',
    'Remove Marker': '删除标记',
  'Do you want to remove this marker?': '您想删除此标记吗？',
  'Cancel': '取消',
  'Remove': '删除',
  'Add to Favourites': '添加到收藏夹',
  'Added to Favourite Locations!': '已添加到收藏地点！',








  };

  static const Map<String, dynamic> ES = {
  'Where will you go next?': '¿A dónde irás después?',
  'Logout': 'Cerrar sesión',
  'Are you sure you want to log out?': '¿Estás seguro de que quieres cerrar sesión?',
  'No': 'No',
  'Yes': 'Sí',
  'Help': 'Ayuda',
  '        Activity': '        Actividad',
  'No action to be taken': 'No se necesita ninguna acción',
  'Friend Requests: %a': 'Solicitudes de amistad: %a',
  '        Upcoming Events': '        Próximos eventos',
  'No upcoming events': 'No hay eventos próximos',
  'Scheduled For: %a': 'Programado para: %a',
  'Dismiss': 'Descartar',
  'Trip Planner': 'Planificador de viajes',
  'Upload Docs': 'Subir documentos',
  'Settings': 'Configuraciones',
  'Socials': 'Sociales',
  'My Trips': 'Viajes',
  'Add New Trip': 'Agregar Nuevo Viaje',
  'View/Edit Trip': 'Ver/Editar Viaje',
  'Delete Trip': 'Eliminar Viaje',
  'Delete this trip?': '¿Eliminar este viaje?',
  'Plan for exciting trips here!': '¡Planea viajes emocionantes aquí!',
  'Map': 'Mapa',
  'Share With Friends': 'Compartir Con Amigos',
  'Share': 'Compartir',
  'You have no friends to invite': 'No tienes amigos para invitar',
  'Shared with %a!': '¡Compartido con %a!',
  'Itinerary Shared': 'Itinerario Compartido',
  '%a has shared an itinerary with you!': '¡%a ha compartido un itinerario contigo!',
  'Please enter your feedback': 'Por favor, ingrese sus comentarios',
  'Thank you for your feedback!': '¡Gracias por sus comentarios!',
  'Error submitting feedback': 'Error al enviar comentarios',
  'Feedback': 'Comentarios',
  'We value your feedback. Please let us know what you think!': ' Valoramos sus comentarios. ¡Por favor, háganos saber qué piensa!',
  'Enter your feedback here': 'Ingrese sus comentarios aquí',
  'Submit': 'Enviar',
  'Frequently Asked Questions': 'Preguntas Frecuentes',
  'Need More Assistance?': '¿Necesitas más ayuda?',
  'Send Feedback': 'Enviar comentarios',
  'How do I reset my password?': '¿Cómo reinicio mi contraseña?',
  'To reset your password, go to the settings page and click on "Change Password". Follow the instructions provided.': 'Para restablecer tu contraseña, ve a la página de configuración y haz clic en "Cambiar contraseña". Sigue las instrucciones proporcionadas.',
  'What type of documents can be uploaded?': '¿Qué tipo de documentos se pueden subir?',
  'WanderWise only allows for .pdf type documents to be uploaded under "Upload Docs".': 'WanderWise solo permite subir documentos de tipo .pdf en la sección de "Subir Documentos".',
  'Am I able to view my itineraries and documents offline?': ' ¿Puedo ver mis itinerarios y documentos sin conexión?',
  'Unfortunately, the current version of the app does not support offline sync. Stay tuned for future updates!': 'Desafortunadamente, la versión actual de la aplicación no admite sincronización sin conexión. ¡Estén atentos a futuras actualizaciones!',
  'Can I sort my trips/documents?': '¿Puedo ordenar mis viajes/documentos?',
  'To sort them to your liking, press & drag your trips/documents!': 'Para ordenarlos a tu gusto, ¡mantén presionado y arrastra tus viajes/documentos!',
  'Email Us': 'Envíanos un correo electrónico',
  'Call Us': 'Llámanos',
  'Have feedback or suggestions?': '¿Tienes comentarios o sugerencias?',
  'Title': 'Título',
  'Start Date': 'Fecha de Inicio',
  'End Date': 'Fecha de Fin',
  'Description': 'Descripción',
  'Start Date: %a \nEnd Date: %a': 'Fecha de Inicio: %a \nFecha de Fin: %a',
  'Choose from Favourite Locations': 'Elige entre los lugares favoritos',
  'Copy & paste your favourite places to your itinerary!': '¡Copia y pega tus lugares favoritos en tu itinerario!',
  'Location copied to clipboard!': '¡Ubicación copiada al portapapeles!',
  'Tap to manage this location': 'Toca para gestionar esta ubicación',
  'Origin': 'Origen',
  'Dest.': 'Destino',
   'Remove Marker': 'Eliminar marcador',
  'Do you want to remove this marker?': '¿Quieres eliminar este marcador?',
  'Cancel': 'Cancelar',
  'Remove': 'Eliminar',
  'Add to Favourites': 'Agregar a Favoritos',
  'Added to Favourite Locations!': '¡Añadido a Lugares Favoritos!',




};

static const Map<String, dynamic> DE = {
  'Where will you go next?': 'Wohin gehst du als nächstes?',
  'Logout': 'Abmelden',
  'Are you sure you want to log out?': 'Möchten Sie sich wirklich abmelden?',
  'No': 'Nein',
  'Yes': 'Ja',
  'Help': 'Hilfe',
  '        Activity': '        Aktivität',
  'No action to be taken': 'Keine Aktion erforderlich',
  'Friend Requests: %a': 'Freundschaftsanfragen: %a',
  '        Upcoming Events': '        Bevorstehende Ereignisse',
  'No upcoming events': 'Keine bevorstehenden Ereignisse',
  'Scheduled For: %a': 'Geplant für: %a',
  'Dismiss': 'Schließen',
  'Trip Planner': 'Reiseplaner',
  'Upload Docs': 'Dokumente hochladen',
  'Settings': 'Einstellungen',
  'Socials': 'Soziales',
  
  
};

}
