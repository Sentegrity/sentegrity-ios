/**
 * * GDStorage.js
 *  
 * Cordova Plugin Java Script
 * Copyright (c)Good Technology 2013
 *@description    Good Dynamics Secure Storage feature including GDFileSystem and GD SQLite
 *The secure file system is part of the.
 *
 *Last Modified : 08/20/12 6am
 *By: Elpidio H. Dela Cruz Jr.
 */

if (!window.Cordova) window.Cordova = window.cordova;


;(function() {
  var cordovaRef = window.PhoneGap || window.Cordova || window.cordova;
  var ProgressEvent = (function() {  
      return function ProgressEvent(type, dict) {
           this.type = type;
           this.bubbles = false;
           this.cancelBubble = false;
           this.cancelable = false;
           this.lengthComputable = false;
           this.loaded = dict && dict.loaded ? dict.loaded : 0;
           this.total = dict && dict.total ? dict.total : 0;
           this.target = dict && dict.target ? dict.target : null;
      };
   }());

  function newProgressEvent(result) {
      var pe = new ProgressEvent();
      pe.lengthComputable = result.lengthComputable;
      pe.loaded = result.loaded;
      pe.total = result.total;
      return pe;
  }
  
//***************************** GDSQLitePlugin ********************************//
/**
 * @class GDSQLitePlugin
 * @classdesc GDSQLitePlugin is a Secure Database object. Use this Object to manipulate the data.
 * 
 * @property {string} name The name of the database.
 * @property {string} version The version of the database.
 * @property {string} displayName The display name of the database.
 * @property {integer} size The size of the database in bytes.
 * 
 */
  var GDSQLitePlugin, GDSQLitePluginTransaction, counter, getOptions, root, exec;
  root = this;
  counter = 0;

  exec = function(method, options, success, error) {
    if (root.sqlitePlugin.DEBUG){
      console.log('GDCSQLitePluginStatic.' + method + '(' + JSON.stringify(options) + ')');
    }
    cordova.exec(success, error, "GDCSQLitePluginStatic", method, [options]);
  };

  GDSQLitePlugin = function(dbargs, openSuccess, openError) {
    if (!dbargs || !dbargs['name']) {
      throw new Error("Cannot create a GDSQLitePlugin instance without a db name");
    }

    this.dbargs = dbargs;
    this.dbname = dbargs.name;
    
    dbargs.name = this.dbname;

    this.openSuccess = openSuccess;
    this.openError = openError;
    var successMsg = "DB opened: " + this.dbname;
    this.openSuccess || (this.openSuccess = function() {
      console.log(successMsg);
    });
    this.openError || (this.openError = function(e) {
      console.log(e.message);
    });
    this.bg = !!dbargs.bgType && dbargs.bgType === 1;
    this.open(this.openSuccess, this.openError);
  };

  GDSQLitePlugin.prototype.openDBs = {};
  GDSQLitePlugin.prototype.txQueue = [];
  GDSQLitePlugin.prototype.databaseFeatures = { isGDSQLitePluginDatabase: true };
  /*
    DEPRECATED AND WILL BE REMOVED:
  */
  GDSQLitePlugin.prototype.features = { isGDSQLitePlugin: true };
  /*
    DEPRECATED AND WILL BE REMOVED:
  */
  GDSQLitePlugin.prototype.executePragmaStatement = function(sql, success, error) {
    if (!sql) throw new Error("Cannot executeSql without a query");
    this.executeSql(sql, [], success, error);
  };

  GDSQLitePlugin.prototype.executeSql = function(sql, values, success, error) {
    if (!sql) throw new Error("Cannot executeSql without a query");
    var mycommand = this.bg ? "backgroundExecuteSql" : "executeSql";
    var query = [sql].concat(values || []);
    var args = {dbargs: { dbname: this.dbname }, ex: {query: query}};
    var mysuccess = function (result) {
      var response = result;
      var payload = {
        rows: { item: function (i) { return response.rows[i] }, length: response.rows.length},
        rowsAffected: response.rowsAffected,
        insertId: response.insertId || null
      };
      success(payload);
    };
    exec(mycommand, args, mysuccess, error);
  };

/**
* @function GDSQLitePlugin#transaction
* @Description Calls the GDSQLitePluginTransaction object instance
* @param {function} fn function that has the transaction as a parameter
* @param {function} error Error callback.
* @param {function} success Success callback.
*/
  GDSQLitePlugin.prototype.transaction = function(fn, error, success) {
    var t = new GDSQLitePluginTransaction(this, fn, error, success);
    this.txQueue.push(t);
    if (this.txQueue.length == 1){
   	console.log('EXECUTING TRANSACTION');
      t.start();
    }
    else {
        console.log('NOT - EXECUTING TRANSACTION');
    }
  };
  GDSQLitePlugin.prototype.startNextTransaction = function(){
    this.txQueue.shift();
    if (this.txQueue[0]){
      this.txQueue[0].start();
    }
  };

  GDSQLitePlugin.prototype.open = function(success, error) {
    console.log('open db: ' + this.dbname);
	  var opts;
    if (!(this.dbname in this.openDBs)) {
      this.openDBs[this.dbname] = true;
      exec("open", this.dbargs, success, error);
    } else {
    	console.log('found db already open ...');
    	success();
    }
  };
  GDSQLitePlugin.prototype.close = function(success, error) {
    if (this.dbname in this.openDBs) {
      delete this.openDBs[this.dbname];
      exec("close", { path: this.dbname }, success, error);
    }
  };
  // API TBD ??? - subect to change:
  GDSQLitePlugin.prototype._closeCrashed = function(success, error) {
	 if(this.dbname in this.openDBs) {
		 delete this.openDBs[this.dbname];
	 }
	 success();
  };
  // API TBD ??? - subect to change:
  GDSQLitePlugin.prototype._deleteDB =
  GDSQLitePlugin.prototype._terminate = function(success,error) {
	    console.log('deleting db: ' + this.dbname);
	    if (this.dbname in this.openDBs) {
	        delete this.openDBs[this.dbname];
	        exec("delete", {path: this.dbname},success,error);
	    }
  };

//***************************** GDSQLTransaction ********************************//
/**
 * @class GDSQLitePluginTransaction
 * @classdesc GDSQLitePluginTransaction is an object that contains methods that allow the user to execute SQL statements against the secure Database.
 * @property {string} db database object which the transaction is executing against.
 * 
 */
  GDSQLitePluginTransaction = function(db, fn, error, success) {
    if (typeof fn !== 'function') {
      // This is consistent with the implementation in Chrome -- it
      // throws if you pass anything other than a function. This also
      // prevents us from stalling our txQueue if somebody passes a
      // false value for fn.
      throw new Error("transaction expected a function")
    }
    this.db = db;
    this.fn = fn;
    this.error = error;
    this.success = success;
    this.executes = [];
    this.executeSql('BEGIN', [], null, function(tx, err){ throw new Error("unable to begin transaction: " + err.message) });
  };

  GDSQLitePluginTransaction.prototype.start = function() {
    try {
      if (!this.fn) {
        return;
      }
      this.fn(this);
      this.fn = null;
      this.run();
    }
    catch (err) {
      // If "fn" throws, we must report the whole transaction as failed.
      this.db.startNextTransaction();
      if (this.error) {
        this.error(err);
      }
    }
  };

/**
* @function GDSQLitePluginTransaction#executeSql
* @Description Execute an SQL statements against the Secure Database.
* @param {string} sql SQL statement to execute.
* @param {array} values Array of arguments for the SQL statement parameters.
* @param {function} successk Success callback.
* @param {function} error Error callback.
* 
* @example
* <p class="p3"><br></p>
* <p class="p4">GDSQLTransaction<span class="s3"> overrides the PhoneGap </span>SQLTransaction <span class="s3">object</span></p>
* <p class="p1">Sample Code for <span class="s1">SQLTransaction</span>: </p>
* <p class="p2"><span class="s2"><a href="http://docs.phonegap.com/en/1.7.0/cordova_storage_storage.md.html">http://docs.phonegap.com/en/1.7.0/cordova_storage_storage.md.html#SQLTransaction</a></span></p>
* <p class="p3"><br></p> 
*/
  GDSQLitePluginTransaction.prototype.executeSql = function(sql, values, success, error) {
    var qid = this.executes.length;

    this.executes.push({
      qid: qid,
      sql: sql,
      params: values || [],
      success: success,
      error: error
    });
  };

  GDSQLitePluginTransaction.prototype.handleStatementSuccess = function(handler, response) {
    if (!handler)
      return;
    var payload = {
      rows: { item: function (i) { return response.rows[i] }, length: response.rows.length},
      rowsAffected: response.rowsAffected,
      insertId: response.insertId || null
    };
    handler(this, payload);
  };

  GDSQLitePluginTransaction.prototype.handleStatementFailure = function(handler, error) {
    if (!handler || handler(this, error)){
      throw error;
    }
  };

  GDSQLitePluginTransaction.prototype.run = function() {

    var batchExecutes = this.executes,
        waiting = batchExecutes.length,
        txFailure,
        tx = this,
        opts = [];
        this.executes = [];

    // var handlerFor = function (index, didSucceed) {
    var handleFor = function (index, didSucceed, response) {
      try {
        if (didSucceed){
          tx.handleStatementSuccess(batchExecutes[index].success, response);
        } else {
          tx.handleStatementFailure(batchExecutes[index].error, response);
        }
      }
      catch (err) {
        if (!txFailure)
          txFailure = err;
      }
      if (--waiting == 0){
        if (txFailure){
          tx.rollBack(txFailure);
        } else if (tx.executes.length > 0) {
          // new requests have been issued by the callback
          // handlers, so run another batch.
          tx.run();
        } else {
          tx.commit();
        }
      }
    }

    for (var i=0; i<batchExecutes.length; i++) {
      var request = batchExecutes[i];
      opts.push({
        qid: request.qid,
        query: [request.sql].concat(request.params),
        sql: request.sql,
        params: request.params
      });
    }

    // NOTE: this function is no longer expected to be called:
    var error = function (resultsAndError) {
        var results = resultsAndError.results;
        var nativeError = resultsAndError.error;
        var j = 0;

        // call the success handlers for statements that succeeded
        for (; j < results.length; ++j) {
          handleFor(j, true, results[j]);
        }

        if (j < batchExecutes.length) {
          // only pass along the additional error info to the statement that
          // caused the failure (the only one the error info applies to);
          var error = new Error('Request failed: ' + opts[j].query);
          error.code = nativeError.code;
          // the following properties are only defined if the plugin
          // was compiled with INCLUDE_SQLITE_ERROR_INFO
          error.sqliteCode = nativeError.sqliteCode;
          error.sqliteExtendedCode = nativeError.sqliteExtendedCode;
          error.sqliteMessage = nativeError.sqliteMessage;

          handleFor(j, false, error);
          j++;
        }

        // call the error handler for the remaining statements
        // (Note: this doesn't adhere to the Web SQL spec...)
        for (; j < batchExecutes.length; ++j) {
          handleFor(j, false, new Error('Request failed: ' + opts[j].query));
        }
    };

    var success = function (results) {
      if (results.length != opts.length) {
        // Shouldn't happen, but who knows...
        error(results);
      }
      else {
        for (var j = 0; j < results.length; ++j) {
          if (!results[j].error) {
            var result = results[j].result;
            handleFor(j, true, result);
          } else {
            var error = new Error('Request failed: ' + opts[j].query);
            error.code = results[j].error.code;
            handleFor(j, false, error);
          }
        }
      }
    };
    mycommand = this.db.bg ? "backgroundExecuteSqlBatch" : "executeSqlBatch";
    var args = {dbargs: { dbname: this.db.dbname }, executes: opts};
    exec(mycommand, args, success, /* not expected: */ error);
  };

  GDSQLitePluginTransaction.prototype.rollBack = function(txFailure) {
    if (this.finalized)
      return;
    this.finalized = true;
    tx = this;
    function succeeded(){
      tx.db.startNextTransaction();
      if (tx.error){
        tx.error(txFailure)
      }
    }
    function failed(tx, err){
      tx.db.startNextTransaction();
      if (tx.error){
        tx.error(new Error("error while trying to roll back: " + err.message))
      }
    }
    this.executeSql('ROLLBACK', [], succeeded, failed);
    this.run();
  };

  GDSQLitePluginTransaction.prototype.commit = function() {
    if (this.finalized)
      return;
    this.finalized = true;
    tx = this;
    function succeeded(){
      tx.db.startNextTransaction();
      if (tx.success){
        tx.success()
      }
    }
    function failed(tx, err){
      tx.db.startNextTransaction();
      if (tx.error){
        tx.error(new Error("error while trying to commit: " + err.message))
      }
    }
    this.executeSql('COMMIT', [], succeeded, failed);
    this.run();
  };

  GDSQLiteFactory = {
    opendb: function() {
  
  console.log('GDSQLiteFactory opendb');

      var errorcb, first, okcb, openargs;
      if (arguments.length < 1) return null;
      first = arguments[0];
      openargs = null;
      okcb = null;
      errorcb = null;
      if (first.constructor === String) {
        openargs = {
          name: first
        };
        if (arguments.length >= 5) {
          okcb = arguments[4];
          if (arguments.length > 5) errorcb = arguments[5];
        }
      } else {
        openargs = first;
        if (arguments.length >= 2) {
          okcb = arguments[1];
          if (arguments.length > 2) errorcb = arguments[2];
        }
      }
      return new GDSQLitePlugin(openargs, okcb, errorcb);
    },
    deleteDb: function(databaseName, success, error) {
        exec("delete", { path: databaseName }, success, error);
    }
  };

//***************************** GDSQLitePlugin openDatabase ********************************//
/**
 * @function GDSQLitePlugin#openDatabase
 * @description This method will return a Secure Database object. Use the Database Object to manipulate the data.
 * @property {string} dbPath The file path of the database.
 * @property {string} version The version of the database.
 * @property {string} displayName The display name of the database.
 * @property {integer} size The size of the database in bytes.
 * @param {function} creationCallback Success callback.
 * @param {function} errorCallback Error callback. 
 * 
 * @example
 * <p class="p3"><br></p>
 * <p class="p1"><span class="s1">gdOpenDatabase</span> overrides the PhoneGap <span class="s1">openDatabase </span>object</p>
 * <p class="p1">Sample Code for <span class="s1">openDatabase</span>: </p>
 * <p class="p2"><span class="s2"><a href="http://docs.phonegap.com/en/1.7.0/cordova_stora">http://docs.phonegap.com/en/1.7.0/cordova_storage_storage.md.html#openDatabase</a></span></p>
 */
  root.sqlitePlugin = {
    sqliteFeatures: { isSQLitePlugin: true },
    openDatabase: GDSQLiteFactory.opendb,
    deleteDatabase: GDSQLiteFactory.deleteDb
  };
  //***** END: Classes *****//
  
  // Install the plugin.
  cordovaRef.addConstructor(function() {

        console.log('sqlite ctor');

		  //*******************************************//
	    if(!window.plugins) window.plugins = {};
        
        openDatabase = sqlitePlugin.openDatabase;

   });
}());

// End GDStorage.js
//*****************************************************************
//leave empty line after

