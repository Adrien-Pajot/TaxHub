//je ne comprends pas encore comment injecter �a dans les controller pour utiliser ce service
 
  
app.factory('configService', function () {
  return {
    txConfig : {
        "filter0":
        {
            "name":"patrimonial"
            ,"label1":"taxons patrimoniaux"
            ,"label2":"patrimonilit�"
            ,"label2":"test"  
        }
        ,"filter1":
        {
            "name":"protection"
            ,"label1":"taxons prot�g�s"
            ,"label2":"protection"
            ,"label2":"Taxons b�n�ficiant d'une protection stricte"  
        }
    },
    gettxConfig : function() {
      return this.txConfig;
    }
  }
});
