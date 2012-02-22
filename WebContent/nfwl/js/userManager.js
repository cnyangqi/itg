var grid;
var win;
var form;

$(function() {
  $('#user_table')
      .datagrid(
          {
            id : 'options',
            title : '用户管理',
            iconCls : 'icon-save',
            width : 900,
            height : 450,
            nowrap : false,
            striped : true,
            collapsible : true,
            url : '/user/getUser',
            sortName : 'id',
            sortOrder : 'desc',
            remoteSort : false,
            idField : 'id',
            pageSize : 10,
            pageNumber : 1,
            queryParams : {
              pageSize : 10,
              pageNumber : 1
            },
            frozenColumns : [ [ {
              field : 'id',
              checkbox : true
            }, {
              title : '姓名',
              field : 'name',
              width : 80,
              sortable : true
            } ] ],
            columns : [
                [
                    {
                      title : '基本资料',
                      colspan : 5
                    },
                    {
                      field : 'opt',
                      title : '操作',
                      width : 100,
                      align : 'center',
                      rowspan : 2,
                      formatter : function(value, rec) {
                        return '<span style="color:red"><a href="javascript:editUser(\''+rec.id+'\')">编辑</a> <a href="javascript:deleteUser(\''+rec.id+'\')">删除</a></span>';
                      }
                    } ], [ {
                  field : 'account',
                  title : '用户名',
                  width : 120
                }, {
                  field : 'telephone',
                  title : '电话',
                  width : 120
                }, {
                  field : 'mobile',
                  title : '手机',
                  width : 120
                }, {
                  field : 'itg_fixedpointname',
                  title : '定点单位',
                  width : 150,
                  rowspan : 2
                }, {
                  field : 'email',
                  title : '电邮',
                  width : 150,
                  rowspan : 2
                } ] ],

            pagination : true,
            rownumbers : true,
            toolbar : [ {
              id : 'btnCancel',
              text : '新建',
              iconCls : 'icon-add',
              handler : function() {
                $('#btncancel').linkbutton('enable');
                newUser();
              }
            }, {
              id : 'btnDelete',
              text : '删除',
              iconCls : 'icon-remove',
              handler : deleteUsers
            }, {
              id : 'btnsearch',
              text : '搜索',
              iconCls : 'icon-search',
              handler : searchData
            } ]
          });
  // 翻页
  var pg = $("#user_table").datagrid("getPager");
  if (pg) {
    $(pg).pagination({
      onBeforeRefresh : function() {
        // alert('before refresh');
      },
      onRefresh : function(pageNumber, pageSize) {
        var queryParams = $('#user_table').datagrid('options').queryParams;
        queryParams.pageNumber = pageNumber;
        queryParams.pageSize = pageSize;
        $('#user_table').datagrid('options').queryParams = queryParams;
        $("#user_table").datagrid('reload');
      },
      onChangePageSize : function() {
        // alert('pagesize changed');
      },
      onSelectPage : function(pageNumber, pageSize) {
        var queryParams = $('#user_table').datagrid('options').queryParams;
        queryParams.pageNumber = pageNumber;
        queryParams.pageSize = pageSize;
        $('#user_table').datagrid('options').queryParams = queryParams;
        $("#user_table").datagrid('reload');
      }
    });
  }

  // 创建搜索
  createSearch();
}

);

$(function() {
  $('#btn-save,#btn-cancel').linkbutton();
  win = $('#user-window').window({
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
var search_name = $("#search_name").val();
var search_fixedpoint = $("#search_fixedpoint").val();
var search_utype = $("#search_utype").val();
// createSearch();
reloadgrid(search_name, search_fixedpoint, search_utype);
}
//创建搜索条
function createSearch() {
  $("<div class='datagrid-btn-separator'></div>'")
      .appendTo(".datagrid-toolbar");
  $(
      "<a style=\"float: left;margin-left:4px;\" mce_style=\"float: left;margin-left:4px;\">"
          + "<span style=\"position:relative;\" mce_style=\"position:relative;\">"
          + "姓名<input id='search_name' name='search_name' >"
          + "单位<input id='search_fixedpoint' name='search_fixedpoint' >"
          + "用户类型<select id='search_utype' name='search_utype'> "
          + " <option value=-1 >全部 </option>"
         // + " <option value=0 >普通用户 </option>"
          + " <option value=1 >普通用户</option>"
          + " <option value=5 >定点单位管理员</option>"
          //+ " <option value=9 >系统管理员</option>"
					+ "</select>" + "<span></a>")
      .appendTo(".datagrid-toolbar");
}

//重新加载
function reloadgrid(search_name, search_fixedpoint, search_utype) {
  // debugger;
  var queryParams = $('#user_table').datagrid('options').queryParams;
  queryParams.name = search_name;
  queryParams.fixedpoint = search_fixedpoint;
  queryParams.utype = search_utype;

  // var queryParams = queryParams:{title:'救助'};
  $('#user_table').datagrid('options').queryParams = queryParams;
  $("#user_table").datagrid('reload');
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
	$('#account').attr("disabled", false); 

  form.url = '/user/save';
}

function deleteUser(deleteid) {
	
  $('#user_table').datagrid('clearSelections');
  $('#user_table').datagrid('selectRecord', deleteid);
  var selected = $('#user_table').datagrid('getSelected');
  if (selected) {
   // alert("'"+selected.id+"'");
    
    if(1==confirm("确定要删除["+selected.name+"]?")){
      $.getJSON("/user/delete/", {
        "id" : "'"+selected.id+"'"
      }, function(deleteUserMsg) {
        if (null != deleteUserMsg && null != deleteUserMsg.success && true == deleteUserMsg.success) {
          $.messager.alert('提示消息', deleteUserMsg.msg, 'info');
          $("#user_table").datagrid('reload');
        }
       
      });
    }
    
  }
  // alert("编辑");
}

function deleteUsers() {
  var ids = [];
  var names = [];
  var rows = $('#user_table').datagrid('getSelections');
  if(rows.length==0){
    $.messager.alert('提示消息', "请选择要操作的对象", 'info');
    
    return;
  }
  for ( var i = 0; i < rows.length; i++) {
    ids.push(rows[i].id);
    names.push(rows[i].name);
  }
  
  if(1==confirm("确定要删除"+names.join(",")+"?")){
    $.getJSON("/user/delete/", {
      "id" : "'"+ids.join("','")+"'"
    }, function(deleteUserMsg) {
      if (null != deleteUserMsg && null != deleteUserMsg.success && true == deleteUserMsg.success) {
        $.messager.alert('提示消息', deleteUserMsg.msg, 'info');
        $("#user_table").datagrid('reload');
      }else{
        
      }
     
    });
  }
}

function editUser(rowid) {
	//debugger;
	
	$('#user_table').datagrid('clearSelections');
	$('#user_table').datagrid('selectRecord', rowid);
  var row = $('#user_table').datagrid('getSelected');
 //var row = $('#user_table').datagrid('selectRecord')(rowid);
 //var row  = $('#user_table').datagrid('selectRecord', rowid);
  if (row) {
    win.window('open');
    form.form('load', row);
    form.url = '/user/save/';
		//$("#account").val("readonly");
     $('#account').attr("disabled", true); 

   // $("#account").readonly=true;
  } else {
    $.messager.show({
      title : '警告',
      msg : '请先选择用户资料。'
    });
  }
}
function saveUser() {
  if ($("#inputFrm").validate().form()) {
    
    if($("#account").val()==''){
      $.messager.alert('提示消息1', "新建用户", 'info');
      $.getJSON("/user/checkAccount/", {
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
                $("#user_table").datagrid('reload');
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
							//alert(saveUserMsg);
              //eval('saveUserMsg=' + saveUserMsg);
              
							 $("#user_table").datagrid('reload');
                win.window('close');
              
            }
          });
       
    }
    
  } else {
    alert("内容填写不正确");
    return;
  }
  
}
function getSelected() {
  var selected = $('#user_table').datagrid('getSelected');
  if (selected) {
    alert(selected.code + ":" + selected.name + ":" + selected.addr + ":"
        + selected.col4);
  }
}
function getSelections() {
  var ids = [];
  var rows = $('#user_table').datagrid('getSelections');
  for ( var i = 0; i < rows.length; i++) {
    ids.push(rows[i].code);
  }
  alert(ids.join(':'));
}
function clearSelections() {
  $('#user_table').datagrid('clearSelections');
}
function selectRow() {
  $('#user_table').datagrid('selectRow', 2);
}
function selectRecord() {
  $('#user_table').datagrid('selectRecord', '002');
}
function unselectRow() {
  $('#user_table').datagrid('unselectRow', 2);
}
function mergeCells() {
  $('#user_table').datagrid('mergeCells', {
    index : 2,
    field : 'addr',
    rowspan : 2,
    colspan : 2
  });
}
function closeWindow() {
  win.window('close');
}


function verifyAccount(account){
	jQuery.ajaxSetup ({cache:false}) ;
	//alert(account);
	 //$('#span_account').innerHTML=account;
	 //document.getElementById("span_account").innerHTML = account;
	 //("span_account").innerHTML = account;      
  $.getJSON("/user/checkAccount/", {
        "account" : account,
				"random":parseInt(Math.random()*100000)

      }, function(checkAccountMsg) {
				//alert(checkAccountMsg);
        if (null != checkAccountMsg && null != checkAccountMsg.success && true == checkAccountMsg.success) {
         // $.messager.alert('提示消息1', checkAccountMsg.msg, 'info');
				 document.getElementById("span_account").innerHTML = checkAccountMsg.msg;
          
        }else if(null != checkAccountMsg && null != checkAccountMsg.msg ){
          document.getElementById("span_account").innerHTML = checkAccountMsg.msg;
        }
      });
	
}
