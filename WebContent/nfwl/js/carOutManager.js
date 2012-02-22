var grid;
var win;
var form;

$(function() {
  $('#carout_table')
      .datagrid(
          {
            id : 'options',
            title : '出车管理',
            iconCls : 'icon-save',
            width : 900,
            height : 450,
            nowrap : false,
            striped : true,
            collapsible : true,
            url : '/carout/getCarOuts',
            sortName : 'code',
            sortOrder : 'desc',
            remoteSort : false,
            idField : 'id',
            pageSize:10,
            pageNumber:1,
            queryParams:{pageSize:10,pageNumber:1},
            frozenColumns : [ [ {
              field : 'id',
              checkbox : true
            }, {
              title : '单位名称',
              field : 'fpname',
              width : 80,
              sortable : true
            } ] ],
            columns : [
                [
                    {
                      title : '基本资料',
                      colspan : 4
                    },
                    {
                      field : 'opt',
                      title : '操作',
                      width : 100,
                      align : 'center',
                      rowspan : 2,
                      formatter : function(value, rec) {
                        //return '<span style="color:red"><a href="javascript:editOrder()">编辑</a> <a href="javascript:deleteOrder()">删除</a></span>';
                      }
                    } ], [ {
                  field : 'delday',
                  title : '配送日期',
                  width : 120
                }, {
                  field : 'carnum',
                  title : '车号',
                  width : 120
                }, {
                  field : 'driver',
                  title : '驾驶员',
                  width : 120
                } , {
                  field : 'cnstatus',
                  title : '状态',
                  width : 120
                } ] ],

            pagination : true,
            rownumbers : true,
            toolbar : [ {
              id : 'btnCancel',
              text : '取消',
              iconCls : 'icon-cancel',
              handler : function() {
                $('#btncancel').linkbutton('enable');
                changeStatues(9);
              }
            }, {
              id : 'btnCancel',
              text : '删除',
              iconCls : 'icon-remove',
              handler : function() {
                $('#btnsave').linkbutton('enable');
                changeStatues(10);
              }
            }, {
              id : 'btnCancel',
              text : '送达',
              iconCls : 'icon-edit',
              handler : function() {
                $('#btnsave').linkbutton('enable');
                changeStatues(2);
              }
            }, {
              id : 'btnCancel',
              text : '完成',
              iconCls : 'icon-ok',
              handler : function() {
                $('#btnsave').linkbutton('enable');
                changeStatues(3);
              }
            }, {
              id : 'btnsearch',
              text : '搜索',
              iconCls : 'icon-search',
              handler : searchData
            } ]
          });
  // 翻页
  var pg = $("#carout_table").datagrid("getPager");
  if (pg) {
    $(pg).pagination({
      onBeforeRefresh: function(){
        // alert('before refresh');
        },
        onRefresh: function(pageNumber, pageSize){
          var queryParams = $('#carout_table').datagrid('options').queryParams;
          queryParams.pageNumber = pageNumber;
          queryParams.pageSize = pageSize;
          $('#carout_table').datagrid('options').queryParams = queryParams;
          $("#carout_table").datagrid('reload');
        },
        onChangePageSize: function(){
        // alert('pagesize changed');
        },
        onSelectPage: function(pageNumber, pageSize){
          var queryParams = $('#carout_table').datagrid('options').queryParams;
          queryParams.pageNumber = pageNumber;
          queryParams.pageSize = pageSize;
          $('#carout_table').datagrid('options').queryParams = queryParams;
          $("#carout_table").datagrid('reload');
        }
      });
    }
  // 创建搜索
  createSearch();
}

);
$(function() {
  $('#btn-save,#btn-cancel').linkbutton();
  win = $('#xxd-window').window({
    closed : true
  });
  form = win.find('form');
});


function resize() {
  $('#carout_table').datagrid('resize', {
    width : 400,
    height : 300
  });
}
function getSelected() {
  var selected = $('#carout_table').datagrid('getSelected');
  if (selected) {
    alert(selected.code + ":" + selected.name + ":" + selected.addr + ":"
        + selected.col4);
  }
}
function getSelections() {
  var ids = [];
  var rows = $('#carout_table').datagrid('getSelections');
  for ( var i = 0; i < rows.length; i++) {
    ids.push(rows[i].code);
  }
  alert(ids.join(':'));
}
function clearSelections() {
  $('#carout_table').datagrid('clearSelections');
}
function selectRow() {
  $('#carout_table').datagrid('selectRow', 2);
}
function selectRecord() {
  $('#carout_table').datagrid('selectRecord', '002');
}
function unselectRow() {
  $('#carout_table').datagrid('unselectRow', 2);
}
function mergeCells() {
  $('#carout_table').datagrid('mergeCells', {
    index : 2,
    field : 'addr',
    rowspan : 2,
    colspan : 2
  });
}

function reloadgrid(status) {
  // debugger;
  var queryParams = $('#carout_table').datagrid('options').queryParams;
  queryParams.status = status;
  // var queryParams = queryParams:{title:'救助'};
  $('#carout_table').datagrid('options').queryParams = queryParams;
  $("#carout_table").datagrid('reload');
}
// 搜索功能
function searchData() {
  var status = $("#order_status").val();

  reloadgrid(status);
}
function editOrder() {
  // var selected = $('#carout_table').datagrid('getSelected');
  // if (selected){
  // alert("编辑"+selected.or_userid+":"+selected.or_memo+":"+selected.or_carrymode);
  // }
  // alert("编辑");

  var selected = $('#carout_table').datagrid('getSelected');
  if (selected) {
    alert(selected.or_id);
    win.window('open');
    form.form('load', '/ordercontroller/getOrderById/' + selected.or_id);
    form.url = '/ordercontroller/update/';
  } else {
    $.messager.show({
      title : '警告',
      msg : '请先选择用户资料。'
    });
  }
}

function deleteOrder() {
  var selected = $('#carout_table').datagrid('getSelected');
  if (selected) {
    alert("删除" + selected.id + ":" + selected.linkman + ":" + selected.or_money
        + ":" + selected.or_status);
  }
  // alert("编辑");
}
function createSearch() {
  $("<div class='datagrid-btn-separator'></div>'")
      .appendTo(".datagrid-toolbar");
  $(
      "<a style=\"float: left;margin-left:4px;\" mce_style=\"float: left;margin-left:4px;\">"
          + "<span style=\"position:relative;\" mce_style=\"position:relative;\">"
          + "<select id='order_status'> "
          + " <option value=0 >全部 </option>"
          + " <option value=1 >已发车</option>"
          + " <option value=2 >已送达</option>"
          + " <option value=3 >已完成 </option>"
          + " <option value=9 >取消</option>"
          + " <option value=10 >删除 </option>" + "  </select>" + "<span></a>")
      .appendTo(".datagrid-toolbar");
  $("#keyword").bind("blur", function() {
    if ($("#keyword").val() == "") {
      $("#keyword").val('请输入关键字 ');
    }
  });
  $("#keyword").bind("focus", function() {
    if ($("#keyword").val() == "请输入关键字") {
      $("#keyword").val('');
    }
  });
}


function newUser() {
  win.window('open');
  form.form('clear');
  form.url = '/baidumappoint/save';
}
function editUser() {
  var row = grid.datagrid('getSelected');
  if (row) {
    win.window('open');
    form.form('load', '/baidumappoint/getUser/' + row.id);
    form.url = '/baidumappoint/update/' + row.id;
  } else {
    $.messager.show({
      title : '警告',
      msg : '请先选择用户资料。'
    });
  }
}
function saveOrder() {
  form.form('submit', {
    url : form.url,
    success : function(data) {
      eval('data=' + data);
      if (data.success) {
        grid.datagrid('reload');
        win.window('close');
      } else {
        $.messager.alert('错误', data.msg, 'error');
      }
    }
  });
}
function changeStatues(todo) {

  var ids = [];
  var fpids = [];
  var rows = $('#carout_table').datagrid('getSelections');
  if(rows.length==0){
    $.messager.alert('提示消息', "请选择要操作的对象", 'info');
    
    return;
  }
  for ( var i = 0; i < rows.length; i++) {
    //alert("e");
    ids.push(rows[i].id);
    fpids.push(rows[i].fpid);
  }
 // alert(ids);
  //alert(fpids);
  $.getJSON("/carout/changeStatues/", {
    "ids" :  "'"+ids.join("','")+"'",
    "fpids" :  "'"+fpids.join("','")+"'",
    "todo" : todo
  }, function(changeStatuesMsg) {
    if (null != changeStatuesMsg && null != changeStatuesMsg.success && true == changeStatuesMsg.success) {
      $.messager.alert('提示消息', changeStatuesMsg.msg, 'info');
      $("#carout_table").datagrid('reload');
    }else{
      
    }
   
  });
}

function closeWindow() {
  win.window('close');
}