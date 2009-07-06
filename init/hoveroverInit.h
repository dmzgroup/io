#ifndef NPSNET_INIT_DOT_H
#define NPSNET_INIT_DOT_H

#include <dmzAppShellExt.h>
#include <QtGui/QWidget>
#include <ui_hoveroverInit.h>

namespace dmz {

class HoveroverInit : public QWidget {

   Q_OBJECT

   public:
      HoveroverInit (AppShellInitStruct &init);
      ~HoveroverInit ();

      AppShellInitStruct &init;
      Ui::hoveroverSetupForm ui;

   protected slots:
      void on_buttonBox_accepted ();
      void on_buttonBox_rejected ();
      void on_buttonBox_helpRequested ();

   protected:
      virtual void closeEvent (QCloseEvent * event);

      Boolean _start;
};

};

#endif // NPSNET_INIT_DOT_H
