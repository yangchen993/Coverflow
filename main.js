
defineClass('ViewController', {
            setText: function() {
            self.textLabel().setText("label的text被改掉了");
            self.textLabel().setTextColor(redColor());
            self.view.setBackgroundColor(require('UIColor').grayColor())
            },
            })
//defineClass('ViewController', {
//            setText: function() {
//            var alertView = require('UIAlertView').alloc().init();
//            alertView.setTitle('Alert');
//            alertView.setMessage('AlertView from js');
//            alertView.addButtonWithTitle('OK');
//            alertView.show();
//            },
//            })

