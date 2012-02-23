var grid;
var win;
var form;

$(function() {
	$('#savecard_table').datagrid({
		id : 'options',
		title : '储值卡管理',
		iconCls : 'icon-save',
		width : 1000,
		height : 500,
		nowrap : true,
		striped : true,
		collapsible : true,
		url : '/savecard/getSaveCard',
		sortName : 'cardno',
		sortOrder : 'desc',
		remoteSort : false,
		idField : 'id',
		pageList : [ 10, 20, 50, 100 ],
		queryParams : {
			pageSize : 10,
			pageNumber : 1
		},
		frozenColumns : [ [ {
			field : 'id',
			checkbox : true
		} ] ],
		columns : [ [ {
			title : '卡号',
			field : 'cardno',
			width : 80,
			sortable : true
		}, {
			title : '密码',
			field : 'cardpwd',
			width : 80,
			sortable : true
		}, {
			title : '金额',
			field : 'money',
			width : 80,
			sortable : true
		}, {
			title : '余额',
			field : 'balance',
			width : 80,
			sortable : true
		}, {
			title : '创建时间',
			field : 'time',
			width : 80,
			sortable : true
		}, {
			title : '销售时间',
			field : 'publishtime',
			width : 80,
			sortable : true
		}, {
			title : '使用时间',
			field : 'usetime',
			width : 80,
			sortable : true
		}, {
			title : '状态',
			field : 'cnstatus',
			width : 80,
			sortable : true
		} ] ],

		pagination : true,
		rownumbers : true,
		toolbar : [ {
			id : 'btnCancel',
			text : '新建',
			iconCls : 'icon-add',
			handler : function() {
				$('#btncancel').linkbutton('enable');
				newSaveCard();
			}
		}, {
			id : 'btnexport',
			text : '导出到excel',
			iconCls : 'icon-sum',
			handler : exportToExcel
		}, {
			id : 'btnimport',
			text : '由CSV导入',
			iconCls : 'icon-sum',
			handler : importFromCsv
		}, {
			id : 'btnDelete',
			text : '删除',
			iconCls : 'icon-remove',
			handler : function() {
				$('#btnDelete').linkbutton('enable');
				changeStatues(-1);
			}
		}, {
			id : 'btnUpdate',
			text : '销售',
			iconCls : 'icon-remove',
			handler : function() {
				$('#btnUpdate').linkbutton('enable');
				changeStatues(1);
			}
		}, {
			id : 'btnsearch',
			text : '搜索',
			iconCls : 'icon-search',
			handler : searchData
		} ]
	});
	// 翻页
	var pg = $("#savecard_table").datagrid("getPager");
	if (pg) {
		$(pg)
				.pagination(
						{
							beforePageText : '第',// 页数文本框前显示的汉字
							afterPageText : '页    共 {pages} 页',
							displayMsg : '当前显示 {from} - {to} 条记录   共 {total} 条记录',
							onBeforeRefresh : function() {
								// alert('before refresh');
							},
							onRefresh : function(pageNumber, pageSize) {
								var queryParams = $('#savecard_table')
										.datagrid('options').queryParams;
								queryParams.pageNumber = pageNumber;
								queryParams.pageSize = pageSize;
								$('#savecard_table').datagrid('options').queryParams = queryParams;
								$("#savecard_table").datagrid('reload');
							},
							onChangePageSize : function() {
								// alert('pagesize changed');
							},
							onSelectPage : function(pageNumber, pageSize) {
								var queryParams = $('#savecard_table')
										.datagrid('options').queryParams;
								queryParams.pageNumber = pageNumber;
								queryParams.pageSize = pageSize;
								$('#savecard_table').datagrid('options').queryParams = queryParams;
								$("#savecard_table").datagrid('reload');
							}
						});
	}
	// 创建搜索
	createSearch();

	// $( "#begin" ).datepicker();
	// $( "#datepicker" ).datepicker();
}

);

$(function() {
	$('#btn-save,#btn-cancel').linkbutton();
	win = $('#newcavecard-window').window({
		closed : true
	});
	form = win.find('form');
});

$(function() {
	$("#inputFrm").validate({
		/* 自定义验证规则 */
		rules : {
			"num" : {
				required : true,
				digits : true,
				min : 0

			},
			"money" : {
				required : true,
				number : true,
				min : 0
			}
		},
		/* 错误提示位置 */
		errorPlacement : function(error, element) {
			error.appendTo(element.siblings("span"));
		}
	});
});

// 搜索功能
function searchData() {
	var status = $("#status").val();
	var createfrom = $("#createfrom").val();
	var createto = $("#createto").val();
	var carno = $("#carno").val();
	// createSearch();
	reloadgrid(status, createfrom, createto, carno);
}
// 创建搜索条
function createSearch() {
	$("<div class='datagrid-btn-separator'></div>'").appendTo(
			".datagrid-toolbar");
	$(
			"<P/><a style=\"float: left;margin-left:4px;\" mce_style=\"float: left;margin-left:4px;\">"
					+ "<span style=\"position:relative;\" mce_style=\"position:relative;\">"
					+ "状态<select id='status' name='status'> "
					+ " <option value='100' >全部 </option>"
					+ " <option value=0 >新建 </option>"
					+ " <option value=1 >已销售</option>"
					+ " <option value=-1 >已删除</option>"
					+ "</select>"
					+ "创建时间:<input id=\"createfrom\" name=\"createfrom\" size=10  readonly onClick=\"getDateString(this,oCalendarChs)\"  />-<input id=\"createto\" name=\"createto\" readonly size=10  onClick=\"getDateString(this,oCalendarChs)\"  /> "
					+ "卡号<input id='carno' name='carno' >" + "<span></a>")
			.appendTo(".datagrid-toolbar");
}

// 重新加载
function reloadgrid(status, createfrom, createto, carno) {
	// debugger;
	var queryParams = $('#savecard_table').datagrid('options').queryParams;
	queryParams.status = status;
	queryParams.createfrom = createfrom;
	queryParams.createto = createto;
	queryParams.carno = carno;

	// var queryParams = queryParams:{title:'救助'};
	$('#savecard_table').datagrid('options').queryParams = queryParams;
	$("#savecard_table").datagrid('reload');
}

// 基本操作

function newSaveCard() {
	// alert($('#user_utype').val());

	if ($('#user_utype').val() != "9") {
		alert("普通用户不可以新建储值卡");
		return;
	}
	win = $('#newcavecard-window').window({
		closed : true
	});

	// form = win.find('form');
	form = $('#inputFrm');

	win.window('open');
	form.form('clear');
	$('#btn-save').attr("disabled", false);
	form.url = '/savecard/create';
}

function exportToExcel() {
	var ids = [];
	var names = [];
	var rows = $('#savecard_table').datagrid('getSelections');
	if (rows.length == 0) {
		$.messager.alert('提示消息', "请选择要操作的对象", 'info');

		return;
	}
	for ( var i = 0; i < rows.length; i++) {
		ids.push(rows[i].id);
		names.push(rows[i].id);
	}

	var page = "savecardExport.jsp?ids=" + "'" + ids.join("','") + "'";
	var bWin = window
			.open(page, 'browseWin',
					'resizable,scrollbars=yes,width=500,height=500,screenX=300,screenY=400');
	bWin.focus();
}

function importFromCsv() {

	var page = "savecardImport.jsp";
	var bWin = window
			.open(page, 'browseWin',
					'resizable,scrollbars=yes,width=500,height=500,screenX=300,screenY=400');
	bWin.focus();
}

function createSaveCard() {
	if ($("#inputFrm").validate().form()) {
		// alert("abc");

		$('#btn-save').attr("disabled", true);
		$.getJSON("/savecard/create/", {
			"size" : $("#num").val(),
			"money" : $("#money").val(),
			"random" : parseInt(Math.random() * 100000)
		}, function(createSaveCardMsg) {
			if (createSaveCardMsg.success) {
				$("#savecard_table").datagrid('reload');
				win.window('close');
			} else {
				$.messager.alert('错误', saveUserMsg.msg, 'error');
			}
		});

	} else {
		alert("内容填写不正确");
		return;
	}

}
function getSelected() {
	var selected = $('#savecard_table').datagrid('getSelected');
	if (selected) {
		alert(selected.code + ":" + selected.name + ":" + selected.addr + ":"
				+ selected.col4);
	}
}
function getSelections() {
	var ids = [];
	var rows = $('#savecard_table').datagrid('getSelections');
	for ( var i = 0; i < rows.length; i++) {
		ids.push(rows[i].code);
	}
	alert(ids.join(':'));
}
function clearSelections() {
	$('#savecard_table').datagrid('clearSelections');
}
function selectRow() {
	$('#savecard_table').datagrid('selectRow', 2);
}
function selectRecord() {
	$('#savecard_table').datagrid('selectRecord', '002');
}
function unselectRow() {
	$('#savecard_table').datagrid('unselectRow', 2);
}
function mergeCells() {
	$('#savecard_table').datagrid('mergeCells', {
		index : 2,
		field : 'addr',
		rowspan : 2,
		colspan : 2
	});
}
function closeWindow() {
	win.window('close');
}

function changeStatues(todo) {

	var ids = [];
	var rows = $('#savecard_table').datagrid('getSelections');
	if (rows.length == 0) {
		$.messager.alert('提示消息', "请选择要操作的对象", 'info');
		return;
	}

	for ( var i = 0; i < rows.length; i++) {
		// alert("e");
		ids.push(rows[i].id);
	}
	// alert(ids);
	// alert(fpids);
	$.getJSON("/savecard/changeStatues/", {
		"ids" : "'" + ids.join("','") + "'",
		"todo" : todo
	}, function(changeStatuesMsg) {
		if (null != changeStatuesMsg && null != changeStatuesMsg.success
				&& true == changeStatuesMsg.success) {
			$.messager.alert('提示消息', changeStatuesMsg.msg, 'info');
			$("#savecard_table").datagrid('reload');
		} else {

		}

	});
}
