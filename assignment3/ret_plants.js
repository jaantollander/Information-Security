// ...
// Plants that will be returned to the client
var retPlants = [];
bookshelf.knex.raw(sql_query).then(function(plants){
    plants.forEach(function(p){
        retPlants.push({
            ’name’:p.name,
            ’color’:p.color,
            ’planttype’:p.planttype,
            ’potsize’:p.potsize
        });
    });
    // Field name from drop - down selection
    var field = req.body.sort_field;
    // Sort the plants
    retPlants.sort(function(a,b){
        var av,bv;
        with (a) { av = eval(field); };
        with (b) { bv = eval(field); };
        return av >= bv ;
    });
    // ...
});
