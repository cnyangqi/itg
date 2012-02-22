var grid;
var win;
var form;

$(function() {
  $('#order_table')
      .datagrid(
          {
            id : 'options',
            title : '订单管理',
            iconCls : 'icon-save',
            width : 900,
            height : 450,
            nowrap : false,
            striped : true,
            collapsible : true,
            url : '/ordercontroller/getOrders',
            sortName : 'code',
            sortOrder : 'desc',
            remoteSort : false,
            idField : 'or_id',
            pageSize:10,
            pageNumber:1,
            queryParams:{pageSize:10,pageNumber:1,status:-1},
            frozenColumns : [ [ {
              field : 'or_id',
              checkbox : true
            }, {
              title : '状态',
              field : 'or_status',
              width : 80,
              sortable : true
            } ] ],
            columns : [
                [
                    {
                      title : '基本资料',
                      colspan : 6
                    },
                    {
                      field : 'opt',
                      title : '操作',
                      width : 100,
                      align : 'center',
                      rowspan : 2,
                      formatter : function(value, rec) {
                        return '<span style="color:red"><a href="javascript:showDetail(\''+rec.or_id+'\')">详情</a>';
                      }
                    } ], [ {
                  field : 'or_userid',
                  title : '客户',
                  width : 120
                }, {
                  field : 'or_money',
                  title : '金额',
                  width : 120
                }, {
                  field : 'or_time',
                  title : '时间',
                  width : 120
                }, {
                  field : 'or_telephone',
                  title : '电话',
                  width : 120
                }, {
                  field : 'or_mobile',
                  title : '手机',
                  width : 150,
                  rowspan : 2
                }, {
                  field : 'or_point',
                  title : '积分',
                  width : 150,
                  rowspan : 2
                } ] ],

            pagination : true,
            rownumbers : true,
            toolbar : [ {
              id : 'btnCancel',
              text : '取消',
              iconCls : 'icon-cancel',
              handler : function() {
                $('#btncancel').linkbutton('enable');
                changeOrder(100);
              }
            }, {
              id : 'btnCancel',
              text : '配送',
              iconCls : 'icon-remove',
              handler : function() {
                $('#btnsave').linkbutton('enable');
                changeOrder(3);
              }
            }, {
              id : 'btnsearch',
              text : '搜索',
              iconCls : 'icon-search',
              handler : searchData
            } ]
          });
  // 翻页
  var pg = $("#order_table").datagrid("getPager");
  if (pg) {
  	$(pg).pagination({
  		onBeforeRefresh: function(){
  			// alert('before refresh');
				},
				onRefresh: function(pageNumber, pageSize){
					var queryParams = $('#order_table').datagrid('options').queryParams;
					queryParams.pageNumber = pageNumber;
					queryParams.pageSize = pageSize;
					$('#order_table').datagrid('options').queryParams = queryParams;
					$("#order_table").datagrid('reload');
				},
				onChangePageSize: function(){
				// alert('pagesize changed');
				},
				onSelectPage: function(pageNumber, pageSize){
					var queryParams = $('#order_table').datagrid('options').queryParams;
					queryParams.pageNumber = pageNumber;
					queryParams.pageSize = pageSize;
					$('#order_table').datagrid('options').queryParams = queryParams;
					$("#order_table").datagrid('reload');
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
  $('#order_table').datagrid('resize', {
    width : 400,
    height : 300
  });
}
function getSelected() {
  var selected = $('#order_table').datagrid('getSelected');
  if (selected) {
    alert(selected.code + ":" + selected.name + ":" + selected.addr + ":"
        + selected.col4);
  }
}
function getSelections() {
  var ids = [];
  var rows = $('#order_table').datagrid('getSelections');
  for ( var i = 0; i < rows.length; i++) {
    ids.push(rows[i].code);
  }
  alert(ids.join(':'));
}
function clearSelections() {
  $('#order_table').datagrid('clearSelections');
}
function selectRow() {
  $('#order_table').datagrid('selectRow', 2);
}
function selectRecord() {
  $('#order_table').datagrid('selectRecord', '002');
}
function unselectRow() {
  $('#order_table').datagrid('unselectRow', 2);
}
function mergeCells() {
  $('#order_table').datagrid('mergeCells', {
    index : 2,
    field : 'addr',
    rowspan : 2,
    colspan : 2
  });
}

function reloadgrid(status) {
  // debugger;
  var queryParams = $('#order_table').datagrid('options').queryParams;
  //alert(queryParams.status);
  queryParams.status = status;
  // var queryParams = queryParams:{title:'救助'};
  $('#order_table').datagrid('options').queryParams = queryParams;
  $("#order_table").datagrid('reload');
}
// 搜索功能
function searchData() {
  var status = $("#order_status").val();
//alert(status);
  reloadgrid(status);
}
function editOrder() {
  // var selected = $('#order_table').datagrid('getSelected');
  // if (selected){
  // alert("编辑"+selected.or_userid+":"+selected.or_memo+":"+selected.or_carrymode);
  // }
  // alert("编辑");

  var selected = $('#order_table').datagrid('getSelected');
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
  var selected = $('#order_table').datagrid('getSelected');
  if (selected) {
    alert("删除" + selected.id + ":" + selected.linkman + ":" + selected.or_money
        + ":" + selected.or_status);
  }
  // alert("编辑");
}
function createSearch() {
  $("<div class='datagrid-btn-separator'></div>'")
      .appendTo(".datagrid-toolbar");
			//0,'新建',1,'已确认',2,'已付款',3,'正在配送',4,'已完成',99,'已删除',100,'取消','未知'
  $(
      "<a style=\"float: left;margin-left:4px;\" mce_style=\"float: left;margin-left:4px;\">"
          + "<span style=\"position:relative;\" mce_style=\"position:relative;\">"
          + "<select id='order_status'> "
          + " <option value=-1 >全部 </option>"
          + " <option value=0 >新建</option>"
          + " <option value=1 >已确认</option>"
          + " <option value=2 >已付款</option>"
          + " <option value=3 >正在配送 </option>"
          + " <option value=4 >已完成</option>"
          + " <option value=99 >已删除</option>"
          + " <option value=100 >已取消 </option>" 
					+ " </select>" 
					+ "<span></a>")
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
function changeOrder(todo) {

  var ids = [];
  var rows = $('#order_table').datagrid('getSelections');
  if(rows.length==0){
    $.messager.alert('提示消息', "请选择要操作的对象", 'info');
    
    return;
  }
	
	if(todo == 3){//配送
		
		for ( var i = 0; i < rows.length; i++) {
	    //alert(rows[i].or_status);
	    if(rows[i].or_status!='已付款'){
				 $.messager.alert('提示消息', "只有已付款订单才可以配送,请检查选中数据", 'info');
				return false;
			}
    }
	}
	
	
  for ( var i = 0; i < rows.length; i++) {
    //alert("e");
    ids.push(rows[i].or_id);
  }
	
  $.getJSON("/ordercontroller/changeOrder/", {
    "ids" :  "'"+ids.join("','")+"'",
    "todo" : todo
  }, function(changeOrderMsg) {
    if (null != changeOrderMsg && null != changeOrderMsg.success && true == changeOrderMsg.success) {
      $.messager.alert('提示消息', changeOrderMsg.msg, 'info');
      $("#order_table").datagrid('reload');
    }else{
      
    }
   
  });
}

function showDetail(or_id){
	 var url = '/order/orderPrint.jsp?or_id=\''+or_id+'\'';
   //url = 'http://new.ithinkgo.com:8822/user/ordermodify.do?cmd=view&or_id=\''+or_id+'\'';
   //page='/nfwl/productarticle/selectproduct.jsp?prdid='+prdid+'&prdname='+prdname+'&prdunit='+prdunit;
    //bWin = window.open(url,'browseWin','width=100%,height=100%，resizable=1 ');
		bWin = window.open (url, 'newwindow', 'height=600, width=800, top=0, left=0, toolbar=yes, menubar=yes, scrollbars=yes, resizable=yes,location=yes, status=no')   

    bWin.focus();
}

function closeWindow() {
  win.window('close');
}