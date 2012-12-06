void logger(Object o, String lvl, String msg) {
  // TODO: consider using enum for log level?
  String ts = timestamp();
  String cn = o.getClass().getSimpleName();
  String logmsg = ts + "\t" + lvl + "\t" + cn + "::" + msg;
  if (lvl == "WARNING") {
    System.err.println(logmsg);
  }
  else if (lvl == "INFO") {
    println(logmsg);
  }
}

String timestamp() {
  return day() + "/" + month() + "/" + year() + " " + hour() + ":" + minute() + ":" + second();
}
