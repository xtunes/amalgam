//= require jquery.jstree
//= require jquery.cookie
var test_data;
$(function(){
  $(".tree-container").jstree({
    "plugins" : ["json_data", "ui", "cookies", "crrm", "contextmenu", "dnd", "search"],
    "json_data" : {
      "data" : UNITS
    },
    "ui" : {
      "initially_select" : INIT_SELECT
    },
    "cookies" : {
      'save_selected' : false
    }
  }).bind("click.jstree", function (event) {
    $.pjax({url: $(event.target).parent().attr('href')+'?locale='+LOCALE, container: '.data-pjax-container'});
  }).bind("remove.jstree", function (e, data) {
    var node = data.rslt.obj;
    if(node.attr('resources')){
      data.rslt.obj.each(function () {
        $.ajax({
          async : false,
          type: 'DELETE',
          url: "/admin/"+node.attr('resources')+'/'+node.data('id')+'.json',
          complete : function (r) {
            var errors = $.parseJSON(r.responseText).errors;
            if($.isEmptyObject(errors)) {
              $(data.rslt.obj).attr("id", "unit-" + r.id);
            }else {
              $.jstree.rollback(data.rlbk);
            }
          }
        });
      });
   }
  }).bind("rename.jstree", function (e, data) {
    var node = data.rslt.obj;
    var content = {};
    content[node.attr('model')] = {};
    content[node.attr('model')][NODE_NAME] = data.rslt.new_name;
    content['resources'] = node.attr('resources');
    content['id'] = node.data('id');
    $.ajax({
      async : false,
      type: 'PUT',
      url: "/admin/"+node.attr('resources')+'/'+node.data('id')+'.json',
      dataType: "json",
      data: content,
      complete: function (r) {
        var errors = $.parseJSON(r.responseText).errors;
        if($.isEmptyObject(errors)) {
          $(data.rslt.obj).attr("id", "unit-" + r.id);
        }else {
          $.jstree.rollback(data.rlbk);
        }
      }
    });
  }).bind("move_node.jstree", function (e, data) {
    var node = data.rslt.o;
    var content = {};
    switch(data.rslt.p)
    {
      case 'last':
        content[node.attr('model')] = {"parent_id" : data.rslt.r.data('id')};
        break;
      case 'before':
        content[node.attr('model')] = {"right_id" : data.rslt.r.data('id')};
        break;
      default:
        content[node.attr('model')] = {"left_id" : data.rslt.r.data('id')};
    }
    content['resources'] = node.attr('resources');
    content['id'] = node.data('id');
    $.ajax({
      async : false,
      type: 'PUT',
      url: "/admin/"+node.attr('resources')+'/'+node.data('id')+'.json',
      dataType: "json",
      data: content,
      complete: function (r) {
        var errors = $.parseJSON(r.responseText).errors;
        if($.isEmptyObject(errors)) {
          $(data.rslt.obj).attr("id", "unit-" + r.id);
        }else {
          $.jstree.rollback(data.rlbk);
        }
      }
    });
  }).bind("create.jstree", function (e, data) {
    var node = data.rslt.parent;
    var content = {};
    content[node.attr('model')] = {"parent_id" : node.data('id')};
    content[node.attr('model')][NODE_NAME] = data.rslt.name;
    content['resources'] = node.attr('resources');
    $.ajax({
      async : false,
      type: 'POST',
      url: "/admin/"+node.attr('resources')+'/create'+'.json',
      dataType: "json",
      data: content,
      complete: function(r){
        var content = $.parseJSON(r.responseText);
        if($.isEmptyObject(content.errors)) {
          $(data.rslt.obj).attr("id", "unit-" + content.id);
          $(data.rslt.obj).attr("resources", node.attr('resources'));
          $(data.rslt.obj).attr("model", node.attr('model'));
          $(data.rslt.obj).attr("href", "/admin/"+node.attr('resources')+'/'+content.id+'/edit');
        }else {
          $.jstree.rollback(data.rlbk);
        }
      }
    });
  });

  $('.search input#content').on("keydown",function(event){
    if(event.keyCode == 13) {
      event.preventDefault();
      return false;
    }
  });
  $('.search input#content').on("input", function(event){
    $(".tree-container").jstree("clear_search");
    $(".tree-container").jstree("search", $('.search input#content')[0].value);
  });
});