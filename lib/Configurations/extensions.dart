

extension databaseFormat on DateTime {

  dbFormat(){
    return toString().replaceAll('T', '');
  }
}