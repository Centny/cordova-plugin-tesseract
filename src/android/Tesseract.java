package com.github.centny.cordova.tess;

import android.util.Base64;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

/**
 * This class echoes a string called from JavaScript.
 */
public class Tesseract extends CordovaPlugin {

  @Override
  public boolean execute(String action, JSONArray args,
                         CallbackContext callbackContext) throws JSONException {
    Runnable runner = null;
    if (action.equals("bootstrap")) {
      runner = () -> this.bootstrap(args, callbackContext);
    } else if (action.equals("recognize")) {
      runner = () -> this.recognize(args, callbackContext);
    }
    if (runner != null) {
      this.cordova.getThreadPool().execute(runner);
      return true;
    }
    return false;
  }

  private void bootstrap(JSONArray args, CallbackContext callback) {
    try {
      if (args.length() > 0) {
        String datapath = args.getString(0);
        String language = args.getString(1);
        com.github.centny.tess.Tesseract.bootstrap(datapath, language);
      } else {
        com.github.centny.tess.Tesseract.bootstrap(this.cordova.getActivity());
      }
      callback.success("ok");
    } catch (Exception e) {
      e.printStackTrace();
      callback.error(e.getMessage());
    }
  }

  private void recognize(JSONArray args, CallbackContext callback) {
    try {
      String sdata = args.getString(0);
      byte[] data = Base64.decode(sdata, Base64.DEFAULT);
      String text;
      if (args.length() == 5) {
        int x, y, w, h;
        x = args.getInt(1);
        y = args.getInt(2);
        w = args.getInt(3);
        h = args.getInt(4);
        text = com.github.centny.tess.Tesseract.recognize(data, x, y, w, h);
      } else {
        text = com.github.centny.tess.Tesseract.recognize(data);
      }
      callback.success(text);
    } catch (Exception e) {
      e.printStackTrace();
      callback.error(e.getMessage());
    }
  }
}
