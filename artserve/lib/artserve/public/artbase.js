

// Load a script from given `url`
function loadScript(url) {
  return new Promise(function (resolve, reject) {
      const script = document.createElement('script');
      script.src = url;

      script.addEventListener('load', function () {
          // The script is loaded completely
          resolve(true);
      });

      document.head.appendChild(script);
  });
}




class Artbase {


  async init( options={} ) {

    const DEFAULTS = {
      database: "artbase.db",
      imageUrl: "https://github.com/pixelartexchange/artbase.js",
    };

    this.settings = Object.assign( {}, DEFAULTS, options );

    console.log( "options:" );
    console.log( options );
    console.log( "settings:" );
    console.log( this.settings );

    console.log( "fetching sql.js..." );
    await loadScript( 'https://cdnjs.cloudflare.com/ajax/libs/sql.js/1.6.1/sql-wasm.js' );
    console.log( "done fetching sql.js" );


    const sqlPromise = initSqlJs({
      locateFile: file => "https://cdnjs.cloudflare.com/ajax/libs/sql.js/1.6.1/sql-wasm.wasm"
    });


    const dataPromise = fetch( this.settings.database ).then(res => res.arrayBuffer());
    const [SQL, buf] = await Promise.all([sqlPromise, dataPromise])
    this.db = new SQL.Database(new Uint8Array(buf));
  }



   _build_query() {
    // get select query as string
    let select = document.querySelector("#select").value
    if (select.length === 0) {
      select = "*"
    } else {
      if (select !== "*") {
        if (!/.*image.*/.test(select)) {
          select = select + ", image"
        }
        if (!/.*id.*/.test(select)) {
          select = select + ", id"
        }
      }
    }
    let where = document.querySelector("#where").value
    let limit = parseInt(document.querySelector("#limit").value)

    let sql = `SELECT ${select} FROM metadata`
    if (where.length > 0) {
      sql += ` WHERE ${where}`
    }
    if (limit > 0) {
      sql += ` LIMIT ${limit}`
    } else {
      sql += " LIMIT 200"
    }

    return sql
  }


  _build_records( result ) {
    let records = []

    if( result.length !== 0) {
      let columns = []

      for(let column of result[0].columns) {
        columns.push(column)
      }

      for(let i=0; i<result[0].values.length; i++) {
        let values = result[0].values[i];
        let o = { attributes: {} }
        for(let j=0; j<columns.length; j++) {
          let column = columns[j]
          // add id to "hidden" system properties / attributes - why? why not?
          if (["id",
               "image",
               "created_at",
               "updated_at" ].includes(column)) {
            o[column] = values[j]
          } else {
            // only add non-null attributes - why? why not?
            if( values[j] != null )
               o.attributes[column] = values[j]
          }
        }
        records.push(o)
      }
  }
  return records
}


  // change to update() or such - why? why not?
  next() {
    const sql = this._build_query()
    const result = this.db.exec( sql )
    const records = this._build_records( result )

    let html = ""
    if (records.length === 0) {
      html = "No results"
    } else {
      console.log(records)
      html = records.map((rec) => {
        let attributes = rec.attributes
        let keys = Object.keys(attributes)
        // note: use "" for attribute quotes
        //         to allow single-quotes in values e.g. Wizard's Hat etc.
        let table = keys.map((key) => {
          return `<tr class="row" data-key="${key}"
                                  data-val="${attributes[key]}">
                        <td>${key}</td>
                        <td>${attributes[key]}</td>
                  </tr>`
        }).join("")

        let img = rec.image

        return `<div class="item">
  <a target="_blank" href="${this.settings.imageUrl}">
     <img src="${img}">
     </a>
  <table>${table}</table>
  </div>`
      }).join("")
    }

    document.querySelector(".container").innerHTML = html
  }
}

