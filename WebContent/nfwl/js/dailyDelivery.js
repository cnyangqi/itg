var grid;
var win;
var form;

$(function() {
  $('#fp_table')
      .datagrid(
          {
            id : 'options',
            title : '今日配送',
            iconCls : 'icon-save',
            width : 900,
            height : 450,
            nowrap : false,
            striped : true,
            collapsible : true,
            url : '/fixedpointcontroller/getDailyDelivery',
            sortName : 'fp_id',
            sortOrder : 'desc',
            remoteSort : false,
            idField : 'fp_id',
            pageSize : 10,
            pageNumber : 1,
            queryParams : {
              pageSize : 10,
              pageNumber : 1
            },
            frozenColumns : [ [ {
              field : 'fp_id',
              checkbox : true
            }, {
              title : '单位名称',
              field : 'fp_name',
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
                        return '<span style="color:red"><a href="javascript:printDailyDelivery(\''+rec.fp_id+'\')">打印</a> <a href="javascript:doDailyDelivery(\''+rec.fp_id+'\')">出车</a></span>';
                      }
                    } ], [ {
                  field : 'fp_code',
                  title : '单位编码',
                  width : 120
                }, {
                  field : 'fp_linker',
                  title : '联系人',
                  width : 120
                }, {
                  field : 'fp_phone',
                  title : '联系电话',
                  width : 120
                }, {
                  field : 'fp_delday',
                  title : '预定配送日期',
                  width : 150,
                  rowspan : 2
                } ] ],

            pagination : true,
            rownumbers : true,
            toolbar : [ {
              id : 'btnCancel',
              text : '打印',
              iconCls : 'icon-print',
              handler : function() {
                $('#btncancel').linkbutton('enable');
                printDailyDelivery();
              }
            }, {
              id : 'btnCarout',
              text : '配送',
              iconCls : 'icon-remove',
              handler : function() {
                $('#btncancel').linkbutton('enable');
                doDailyDelivery();
              } 
            }, {
              id : 'btnsearch',
              text : '搜索',
              iconCls : 'icon-search',
              handler : searchData
            } ]
          });
  // 翻页
  var pg = $("#fp_table").datagrid("getPager");
  if (pg) {
    $(pg).pagination({
      onBeforeRefresh : function() {
        // alert('before refresh');
      },
      onRefresh : function(pageNumber, pageSize) {
        var queryParams = $('#fp_table').datagrid('options').queryParams;
        queryParams.pageNumber = pageNumber;
        queryParams.pageSize = pageSize;
        $('#fp_table').datagrid('options').queryParams = queryParams;
        $("#fp_table").datagrid('reload');
      },
      onChangePageSize : function() {
        // alert('pagesize changed');
      },
      onSelectPage : function(pageNumber, pageSize) {
        var queryParams = $('#fp_table').datagrid('options').queryParams;
        queryParams.pageNumber = pageNumber;
        queryParams.pageSize = pageSize;
        $('#fp_table').datagrid('options').queryParams = queryParams;
        $("#fp_table").datagrid('reload');
      }
    });
  }

  // 创建搜索
  createSearch();
}

);

$(function() {
  $('#btn-save,#btn-cancel').linkbutton();
  win = $('#carout-window').window({
    closed : true
  });
  form = win.find('form');
});

$(function() {
  $("#inputFrm").validate({
    /* 自定义验证规则 */
    rules : {
      "name" : {
        required : true
      },
      account : {
        required : true
      },
      email : {
        email : true
      }
    },
    /* 错误提示位置 */
    errorPlacement : function(error, element) {
      error.appendTo(element.siblings("span"));
    }
  });
});


//搜索功能
function searchData() {
var search_name = $("#search_fp_name").val();
var search_linker = $("#search_fp_linker").val();
var search_addr = $("#search_fp_address").val();
// createSearch();
reloadgrid(search_name, search_linker, search_addr);
}
//创建搜索条
function createSearch() {
  $("<div class='datagrid-btn-separator'></div>'")
      .appendTo(".datagrid-toolbar");
  $(
      "<a style=\"float: left;margin-left:4px;\" mce_style=\"float: left;margin-left:4px;\">"
          + "<span style=\"position:relative;\" mce_style=\"position:relative;\">"
          + "单位名称<input id='search_fp_name' name='search_fp_name' >"
          + "联系人<input id='search_fp_linker' name='search_fp_linker' >"
          + "单位地址<input id='search_fp_address' name='search_fp_address' > "
          + "<span></a>")
      .appendTo(".datagrid-toolbar");
}

//重新加载
function reloadgrid(search_name, search_linker, search_addr) {
   //debugger;
 // var queryParams = $('#fp_table').datagrid('options').queryParams;
  var queryParams = $('#fp_table').datagrid('options').queryParams;
  queryParams.name = search_name;
  queryParams.linker = search_linker;
  queryParams.addr = search_addr;

  // var queryParams = queryParams:{title:'救助'};
  $('#fp_table').datagrid('options').queryParams = queryParams;
  $("#fp_table").datagrid('reload');
}


//基本操作

function newUser() {
  // alert($('#user_utype').val());
  if ($('#user_utype').val() == "1") {
    alert("普通用户不可以新建用户");
    return;
  }
  win.window('open');
  form.form('clear');
  form.url = '/usercontroller/save';
}


function deleteUsers() {
  var ids = [];
  var names = [];
  var rows = $('#fp_table').datagrid('getSelections');
  if(rows.length==0){
    $.messager.alert('提示消息', "请选择要操作的对象", 'info');
    
    return;
  }
  for ( var i = 0; i < rows.length; i++) {
    ids.push(rows[i].id);
    names.push(rows[i].name);
  }
  
  if(1==confirm("确定要删除"+names.join(",")+"?")){
    $.getJSON("/usercontroller/delete/", {
      "id" : "'"+ids.join("','")+"'"
    }, function(deleteUserMsg) {
      if (null != deleteUserMsg && null != deleteUserMsg.success && true == deleteUserMsg.success) {
        $.messager.alert('提示消息', deleteUserMsg.msg, 'info');
        $("#fp_table").datagrid('reload');
      }else{
        
      }
     
    });
  }
}
function doDailyDelivery(fp_id){
	if(fp_id==null||fp_id==''){
    
    var ids = [];
    var names = [];
    var rows = $('#fp_table').datagrid('getSelections');
    if(rows.length==0){
      $.messager.alert('提示消息', "请选择要操作的对象", 'info');
      
      return;
    }
    for ( var i = 0; i < rows.length; i++) {
      ids.push(rows[i].fp_id);
      names.push(rows[i].fp_name);
    }
    
    fp_id = "'"+ids.join("','")+"'";
  }
	
//String ids,String driver,String carnum

var sdriver = window.prompt("请输入驾驶员"); 
var scarnum = window.prompt("请输入车号:"); 
  $.getJSON("/caroutcontroller/carOut/", {
    "ids" :  fp_id,
    "driver" : sdriver,
    "carnum" : scarnum
  }, function(carOutMsg) {
    if (null != carOutMsg && null != carOutMsg.success && true == carOutMsg.success) {
      $.messager.alert('提示消息', carOutMsg.msg, 'info');
      $("#fp_table").datagrid('reload');
    }else{
      
    }
   
  });
	
}
function printDailyDelivery(fp_id) {
	if(fp_id==null||fp_id==''){
		
		var ids = [];
	  var names = [];
	  var rows = $('#fp_table').datagrid('getSelections');
	  if(rows.length==0){
	    $.messager.alert('提示消息', "请选择要操作的对象", 'info');
	    
	    return;
	  }
	  for ( var i = 0; i < rows.length; i++) {
	    ids.push(rows[i].fp_id);
	    names.push(rows[i].fp_name);
	  }
		
		fp_id = ids.join("','");
  }
	
	
  var url = '/nfwl/dddw/dddwOrderPrint.jsp?fp_id=\''+fp_id+'\'';
  
   //page='/nfwl/productarticle/selectproduct.jsp?prdid='+prdid+'&prdname='+prdname+'&prdunit='+prdunit;
    bWin = window.open(url,'browseWin','resizable=yes,scrollbars=yes,status=yes,width=100%,height=100%');
    bWin.focus();
}
function saveUser() {
  if ($("#inputFrm").validate().form()) {
    
    if($("#account").val()==''){
      $.messager.alert('提示消息1', "新建用户", 'info');
      $.getJSON("/usercontroller/checkAccount/", {
        "account" : $("#account").val()
      }, function(checkAccountMsg) {
        if (null != checkAccountMsg && null != checkAccountMsg.success && true == checkAccountMsg.success) {
          $.messager.alert('提示消息1', checkAccountMsg.msg, 'info');
          form.form('submit', {
            url : form.url,
            success : function(saveUserMsg) {
              eval('saveUserMsg=' + saveUserMsg);
              //alert(saveUserMsg.success);
              if (saveUserMsg.success) {
                $("#fp_table").datagrid('reload');
                win.window('close');
              } else {
                $.messager.alert('错误', saveUserMsg.msg, 'error');
              }
            }
          });
        }else if(null != checkAccountMsg && null != checkAccountMsg.msg ){
          $.messager.alert('提示消息2', checkAccountMsg.msg, 'info');
        }
      });
    }else{

          form.form('submit', {
            url : form.url,
            success : function(saveUserMsg) {
              eval('saveUserMsg=' + saveUserMsg);
              
              if (saveUserMsg.success) {
                $("#fp_table").datagrid('reload');
                win.window('close');
              } else {
                $.messager.alert('错误', saveUserMsg.msg, 'error');
              }
            }
          });
       
    }
    
  } else {
    alert("内容填写不正确");
    return;
  }
  
}
function getSelected() {
  var selected = $('#fp_table').datagrid('getSelected');
  if (selected) {
    alert(selected.code + ":" + selected.name + ":" + selected.addr + ":"
        + selected.col4);
  }
}
function getSelections() {
  var ids = [];
  var rows = $('#fp_table').datagrid('getSelections');
  for ( var i = 0; i < rows.length; i++) {
    ids.push(rows[i].code);
  }
  alert(ids.join(':'));
}
function clearSelections() {
  $('#fp_table').datagrid('clearSelections');
}
function selectRow() {
  $('#fp_table').datagrid('selectRow', 2);
}
function selectRecord() {
  $('#fp_table').datagrid('selectRecord', '002');
}
function unselectRow() {
  $('#fp_table').datagrid('unselectRow', 2);
}
function mergeCells() {
  $('#fp_table').datagrid('mergeCells', {
    index : 2,
    field : 'addr',
    rowspan : 2,
    colspan : 2
  });
}
function closeWindow() {
  win.window('close');
}