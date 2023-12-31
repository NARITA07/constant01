<%@page import="com.constant01.model.MemberDTO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko" xmlns="http://www.w3.org/1999/xhtml"><head>
<meta charset="utf-8">
<meta http-equiv="Content-Script-Type" content="text/javascript">
<meta http-equiv="Content-Style-Type" content="text/css">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimun-scale=1.0, user-scalable=no, target-densitydpi=medium-dpi, viewport-fit=cover">
<link rel="shortcut icon" href="/common/front/health/images/favicon.ico" type="image/x-icon">
<link rel="icon" href="/common/front/health/images/favicon.ico" type="image/x-icon">
<title>CONSTANT 메디컬 온라인 진료예약</title>
	<link type="text/css" rel="stylesheet" href="../../../../resources/css/default.css">
	<link type="text/css" rel="stylesheet" href="../../../../resources/css/swiper-bundle.min.css">
	<link type="text/css" rel="stylesheet" href="../../../../resources/css/reservation.css">
	<script type="text/javascript" src="../../../../resources/js/jquery-1.11.0.min.js"></script>
	<script type="text/javascript" src="../../../../resources/js/jquery-ui.min.js"></script>
	<script type="text/javascript" src="../../../../resources/js/design.js"></script>
	<script type="text/javascript" src="../../../../resources/js/swiper.min.js"></script>
	<script type="text/javascript" src="../../../../resources/js/rolling.js"></script>
	<script type="text/javascript" src="../../../../resources/js/scrolla.jquery.js"></script>
	<script type="text/javascript" src="../../../../resources/js/scrolloverflow.js"></script>
	<script type="text/javascript" src="../../../../resources/js/fullpage.js"></script>
	<script type="text/javascript" src="../../../../resources/js/scrolla.jquery.js"></script>
	<script type="text/javascript" src="../../../../resources/js/common.js"></script>
	<script type="text/javascript" src="../../../../resources/js/CommonUtil.c3r-custom.js"></script>
	<% 
         MemberDTO member = (MemberDTO)session.getAttribute("login");
	%>
	<script type="text/javascript">
		$(document).ready(function(){
			//빠른일정조회
			fn_SearchFastSchedule();
			//의료진예약연령제한
			var birth = $("#userBirthDt").val().split("-").join("");
			var age = ageCheck(birth, "1");
			if(($("#resvAdultYn").val() == "O" && age < 18) || ($("#resvAdultYn").val() == "M" && age < 14) || ($("#resvAdultYn").val() == "H" && age < 16)
				|| ($("#resvAdultYn").val() == "E" && age < 13) || ($("#resvAdultYn").val() == "I" && age < 7)){
				$("#adultConfirm").show();
			}
			//호흡기알레르기내과 선택 시, 안내문구 띄우기(2023.03.09 류은지 요청) --(selDeptNo)운영은 104/개발은107
			// if("80" == "104"){
			// 	alert("호흡기알레르기내과는 전화 예약 및 외래 방문만 가능합니다. 불편을 드려 대단히 죄송합니다.\n1주일 이내 발생한 호흡기 증상으로 인한 외래 진료 시에는 코로나 PCR 검사결과지(3일 내)를 지참하셔야 합니다.");
			// 	$("#frm").attr("action","/home/reserveNew/step1Pop.do").submit();
			// }

			$(document).on("click",".popUpClose",function(){
				$(".adultConfirm").hide();
				fn_Step(2);
			});
			fn_SchList("12");

			$(document).on("click",".btn_close",function(){
				window.close();
			});

			$(document).on("click",".popClose",function(){
				$("#resvConfirm").hide();
			});

			$(document).on("click",".btn_reset",function(){
				$(this).parent("span").remove();
				var selTimeHtml = "<span class='empty_txt'>선택된 진료일시가 없습니다.</span>";
				$("#selTime").append(selTimeHtml);
				//$(".monli").removeClass("on");
				//$(".aftli").removeClass("on");
				$("#time_scadual > li").removeClass("on");
				$("#resvDd").val("");
				$("#resvHh").val("");
			});

			$(document).on("click", ".sel_possible", function(){
				$(".sel_possible").removeClass("sel_date");
				$(this).addClass("sel_date");
			});
		});
	</script>
	<script type="text/javascript">
		var G_ARR_DEPT_INFO = new Array();
		var G_ARR_TIME_INFO = new Array();
		function ageCheck(str1,str2){
			var divisionCode = str2.substring(0, 1);
			var dateOfBirth="";
			var age = "";
			if(str1 != null && str1 !="" && str1 != undefined && str1.length < 7){
				if(divisionCode == 1 || divisionCode == 2 || divisionCode == 5 || divisionCode == 6){
					// 한국인 1900~, 외국인 1900~
					dateOfBirth = "19"+str1;
				}else if(divisionCode == 3 || divisionCode == 4 || divisionCode == 7 || divisionCode == 8){
					// 한국인 2000~, 외국인 2000~
					dateOfBirth = "20"+str1;
				}else if(divisionCode == 9 || divisionCode == 0){
					// 한국인 1800~
					dateOfBirth = "18"+str1;
				}
			}else if( str1.length < 9){
				dateOfBirth = str1;
			}else{
				dateOfBirth = "";
			}
			if(dateOfBirth != ""){
				dateOfBirth = dateOfBirth.substr(0,4)+"-"+dateOfBirth.substr(4,2)+"-"+dateOfBirth.substr(6,2);
				var date = new Date();
				var birthDate = new Date(dateOfBirth);
				if( str1 != null && str1 != '' ){
					age = date.getFullYear() - birthDate.getFullYear() ;
					birthDate.setFullYear(date.getFullYear()); // 생년월일 객체의 연도를 오늘 날짜 객체의 연도로 변경
					if( date > birthDate) { // 같은 연도가 된 객체를 비교하여 월일이 지났는지 여부 판단
						age; // 생일이 안지났으면 나이
					} else {
						age--; //
					}
				}
			}else{
				age =0;
			}
			return age;
		}
		
		
		
		//여기서부터 달력 예약하기
		
		
		
		function fn_SchList(month){
			$("#schMonth").val(month);
			$.ajax({
				type : "POST",
				url  : "/home/reserveNew/resvProfScheduleListAjax.do",
				data : {
					"emrDeptCd" : $("#emrDeptCd").val(),
					"emrProfCd" : $("#selEmpNo").val(),
					"schMonth"  : $("#schYear").val()+"-"+(parseInt($("#schMonth").val()) < 10 ? "0":"")+$("#schMonth").val(),
					"ptNo"		: $("#ptNo").val()
				},
				dataType : "text",
				success  : function(data){
					var rData = $.parseJSON(data);
					if( rData != null && rData != undefined && rData.length > 0 ){//sel_date
						$(".schDay").each(function(idx){
							if( $(this).text().trim() != "" ){
								var day = $(this).text().trim();
								$.each(rData,function(index,item){
									if( item.basedd != undefined && item.basedd != null && item.basedd != "" ){
										var basedd = String(item.basedd);
										basedd = basedd.substring(6,8);
										if( day == basedd ){
											$(".schDay").eq(idx).attr("href","javascript:fn_selDate(\'"+basedd+"\');").css("cursor","pointer;").addClass("sel_possible");
										}
									}
								});
							}
						});
					}
				},
				error:function(request,status,error){
					alert("처리 중 오류가 발생되었습니다.\nerror:"+error+"request:"+request+"status:"+status);
				}
			});
		}
		//날짜 선택하면 해당 날짜의 시간이 뜨도록
		function fn_selDate(selDate){
			$("#schDate").val(selDate);
			$("#time_monScadual > li").remove();
			$("#time_aftScadual > li").remove();
			$(".monTag").removeClass("sty2");
			$(".aftTag").removeClass("sty2");
			$(".btn_reset").trigger("click");
			$("#resvDd").val("");
			$("#resvHh").val("");
			//$("#time_scadual > li").remove();
			$("div.sel_time > p").remove();
			$("div.sel_time > div").remove();
			var scheDate = $("#schYear").val()+"-"+(parseInt($("#schMonth").val()) < 10 ? "0":"")+$("#schMonth").val()+"-"+selDate;
			var orddd = $("#schYear").val()+(parseInt($("#schMonth").val()) < 10 ? "0":"")+$("#schMonth").val()+selDate;
			$.ajax({
				type : "POST",
				url  : "/home/reserveNew/resvProfScheduleTimeListAjax.do",
				data : {
					"headHspCd" : $("#hspCd").val(),
					"dpCd"      : $("#selDeptCd").val(),
					"emrProfCd" : $("#selEmpNo").val(),
					"emrDeptCd" : $("#emrDeptCd").val(),
					"schDate"   : scheDate,
					"ptNo"		: $("#ptNo").val(),
					"orddd"     : orddd
				},
				dataType : "text",
				success  : function(data){
					var rData = $.parseJSON(data);
					//주간스케줄이 없으면 진료예약 시간이 뜨지 않는다.
					if( rData.weekList != null && rData.weekList != undefined && rData.weekList.length > 0 ){
						//[1]변수정의
						var weekList    = rData.weekList;
						var timeList    = rData.timeList;
						var arrDept     = new Array();
						var arrUniqDept = new Array();
						/*
						//[2]스케쥴을 요일별 오름차순 정렬
						weekList.sort(function(a,b){
						    return a.dayofweek > b.dayofweek ? -1 : a.dayofweek < b.dayofweek ? 1 : 0;
						});
						//[3]스케쥴을 요일별 합침.
						var newWeekList = new Array();
						var prevWeekNm  = "";
						$.each(weekList,function(index,item){
							if( prevWeekNm != item.dayofweek ){
								newWeekList.push(item);
							}else{
								var prevData = newWeekList[index-1];
								if( prevData.ampmflag == "오전" && item.ampmflag == "오후" ){
									newWeekList[index-1].ampmflag = "전일";
								}else if( prevData.ampmflag == "오후" && item.ampmflag == "오전" ){
									newWeekList[index-1].ampmflag = "전일";
								}
							}
							prevWeekNm = item.dayofweek;
						});
						*/
						//[4]센터/진료과 중복제거
						if( timeList != undefined && timeList.length > 0 ){
							$.each(timeList,function(index,item){
								if( item.centnm != "" )		arrDept.push(item.centnm+":"+item.centcd);
								else						arrDept.push(item.orddeptnm+":"+item.orddeptcd);
							});
						}
						$.each(arrDept,function(key,value){
							if( $.inArray(value,arrUniqDept) === -1 ) arrUniqDept.push(value);
						});
						//[5]전역변수에 arrDept 담기
						G_ARR_DEPT_INFO = arrUniqDept;
						G_ARR_TIME_INFO = timeList;
						console.log(arrUniqDept);
						//[6]센터/과 상단 라디오 표출
						var sRadioHtml = "<div class=\"agree_check mt20\" style=\"text-align:center;\">";
						var oneRadioId = "";
						$.each(arrUniqDept,function(index,item){
							var arrCenterInfo = item.split(":");
							var centerCd = arrCenterInfo[1];
							var centerNm = arrCenterInfo[0];
							var weekNm   = G_Util.getWeekInfo(scheDate,"KOR");
							$.each(weekList,function(index2,item2){
								var tmpCenterNm = "";
								if( item2.centnm != "" )	tmpCenterNm = item2.centnm;
								else						tmpCenterNm = item2.orddeptnm;
								if( tmpCenterNm == centerNm && item2.dayofweek == weekNm ){
									centerNm += "("+item2.ampmflag+")";
								}
							});
							centerNm = centerNm.replace("전일","종일");
							sRadioHtml += "<label for='"+centerCd+"' class='ch'>";
							sRadioHtml += "<input type='radio' id='"+centerCd+"' name='centerCd' onclick='javascript:fn_SelCenter(this);'><span>"+centerNm+"</span>";
							sRadioHtml += "</label>";
							oneRadioId = centerCd;
						});
						sRadioHtml += "</div>";
						$("div.sel_time").append(sRadioHtml);
						//[7]센터코드가 하나만 있는경우 선택 없이 첫번째 스케쥴 표출;;
						if( arrUniqDept.length == 1 ){
							$("#"+oneRadioId).trigger("click");
						}
					}
				},
				error:function(request,status,error){
					alert("처리 중 오류가 발생되었습니다.\nerror:"+error+"request:"+request+"status:"+status);
				}
			});
		}
		//예약가능시각 로딩
		function fn_SelCenter(obj){
			var radioDeptCd = $(obj).attr("id");
			var sHtml = "";
			$("div.slot_wrap").remove();
			$(obj).parent().parent().find("span").css({"font-weight":"400"});
			$(obj).parent().find("span").css({"font-weight":"700"});
			//console.log(G_ARR_TIME_INFO);
			$.each(G_ARR_TIME_INFO,function(index,item){
				var deptCd = item.centcd;
				if( deptCd == null || deptCd == undefined || deptCd == "" || deptCd == "-" ){
					deptCd = item.orddeptcd;
				}
				if( radioDeptCd == deptCd ){
					var sTime = String(item.ordtm);
					sTime = sTime.substring(0,2)+":"+sTime.substring(2,4);
					sHtml += "<li><a href=\"javascript:void(0);\" onclick=\"javascript:fn_SelTime(this,'"+item.centcd+"','"+item.orddeptcd+"','"+sTime+"');\"><span>"+sTime+"</span></a></li>";
				}
			});
			var oDiv = $("<div/>").addClass("slot_wrap sty2");
			var oUl  = $("<ul/>").addClass("time_slot_list fix");
			oUl.append("<ul class=\"time_slot_list fix\">"+sHtml+"</ul>");
			oDiv.append(oUl);
			$("div.sel_time").append(oDiv);
		}
		function fn_SelTime(obj,centcd,orddeptcd,sTime){
			var setMonth = parseInt($("#schMonth").val()) < 10 ? "0"+$("#schMonth").val() : $("#schMonth").val();
			var setDate  = $("#schDate").val();
			$("ul.time_slot_list > li").removeClass("on");
			$(obj).parent().addClass("on");
			$("#selTime > span").remove();
			var selTimeHtml = "<span>"+$("#schYear").val()+"-"+setMonth+"-"+setDate+" "+sTime+" <a href='javascript:void(0);' class='btn_reset'><span class='skip'>초기화</span></a></span>";
			$("#selTime").append(selTimeHtml);
			$("#resvDd").val($("#schYear").val()+"-"+setMonth+"-"+setDate);
			$("#resvHh").val(sTime);
			$("#emrCenterCd").val(centcd);
			$("#emrDeptCd").val(orddeptcd);
		}
		
		function fn_MonthSearch(year, month){
			if(month==0){
				year = parseInt(year)-1;
				month = 12;
			}
			if(month > 12){
				year = parseInt(year)+1;
				month = 1;
			}
			$("#schYear").val(year);
			$("#schMonth").val(month);
			$("#frm").attr("action","/home/reserveNew/step3Pop.do");
			$("#frm").submit();
		}

		function fn_Step(step){
			if(step == 4 && $("#resvHh").val() == ""){
				alert("진료일시를 선택해 주세요.");
				return false;
			}
			if(step == 4 && $("#resvHh").val() != ""){
				$("#strTime").text($("#resvDd").val()+" "+$("#resvHh").val());
				$("#resvConfirm").show();
				return false;
			}
			if(step == "5"){//예약실행
				//resv_flag : 예약구분( HOME: 홈페이지 온라인 예약,COOP: 진협예약 )
				if($("#resv_flag").val() == 'COOP'){
					//kdw추가 ( 진협 프로세스 이동 )
					$("#frm").attr("action","/refer/reservation/requ_res_registProc.do").submit();
				}else{
					//주요증상 입력 기능추가
					//[2023.04.11 요청자:류은지]진료과가 '산부인과'일경우, 주요증상 필수입력.
					//[2023.06.30 요청자:류은지]모든진료과 주요증상 입력받으나 필수입력 아님. 단, '산부인과'에서 '초진'일 경우에만 필수입력.
					if($("#selDeptNm").val() == "산부인과"){
						//산부인과 초진여부 확인
						var rsvDate = $("#schYear").val()+(parseInt($("#schMonth").val()) < 10 ? "0":"")+$("#schMonth").val()+$("#schDate").val();
						$.ajax({
							type : "POST",
							url  : "/home/reserveNew/resvDeptFirstCheckAjax.do",
							data : {
								//"ptNo"		: "00018048",
								"ptNo"		: $("#ptNo").val(),
								"emrDeptCd" : $("#emrDeptCd").val(),
								"emrProfCd" : $("#selEmpNo").val(),
								"schDate"   : rsvDate
							},
							dataType : "text",
							success  : function(data){
								var rData = $.parseJSON(data);
								//fsexamflag : D 과초진, F 병원초진 , S 상병초진, R 재진, 4 응급실경유, 5 입원경유
								if(rData == "D" || rData == "F" || rData == "S"){
									if( $("#symMemo").val() == "" ){
						                alert("주요증상을 입력해 주세요.");
										$("#symMemo").focus();
						                return false;
						            }else{
						            	//alert("주요증상을 입력했다.");
						            	$("#frm").attr("action","/home/reserveNew/resvProc.do").submit();
						            }
								}else{
									//alert("필수값이 아니다.");
									$("#frm").attr("action","/home/reserveNew/resvProc.do").submit();
								}
							},
							error:function(request,status,error){
								alert("처리 중 오류가 발생되었습니다.\nerror:"+error+"request:"+request+"status:"+status);
							}
						});
					}else{
						$("#frm").attr("action","/home/reserveNew/resvProc.do").submit();
					}
				}
			}else{
				$("#frm").attr("action","/home/reserveNew/step"+step+"Pop.do").submit();
			}
		}
		
		function fn_SearchFastSchedule(){
			$("div#fastDiv").children().remove();
			$("div#fastDiv").hide();
			$("span#fastTxt").hide();
			$.ajax({
				type : "POST",
				url  : "/home/reserveNew/resvProfFastScheduleListAjax.do",
				data : {
					"ptNo"      : $("#ptNo").val(),
					"emrDeptCd" : $("#emrDeptCd").val(),
					"emrProfCd" : $("#selEmpNo").val()
				},
				dataType : "text",
				success  : function(data){
					var rData = $.parseJSON(data);
					if( rData != null && rData != undefined ){
						if( rData.length > 0 ){
							var sHtml = "";
							sHtml += "<ul class=\"quick_reserv_list\">";
							for( var i=0; i<rData.length; i++ ){
								console.log(rData);
								//예약파라미터
								var fnParam   = "";
								var centcd    = rData[i].centcd;
								var orddeptnm = rData[i].orddeptnm;
								var minoddd   = rData[i].minoddd;
								var resvDd    = "";
								var resvHh    = "";
								if( minoddd != undefined && minoddd != "" ){
									var arr_minoddd = minoddd.split(" ");
									resvDd = arr_minoddd[0];
									resvDd = "20"+resvDd;
									resvHh = arr_minoddd[1];
								}
								fnParam = "'"+centcd+"','"+orddeptnm+"','"+resvDd+"','"+resvHh+"'";
								//예약목록
								sHtml += "<li>";
								sHtml += "["+rData[i].orddeptnm+"] 20"+rData[i].minoddd;
								sHtml += "<a href=\"javascript:void(0);\" class=\"btn_quick_reserv\" onclick=\"javascript:fn_ActionFastSchedule("+fnParam+");\"><span>예약하기</span></a>";
								sHtml += "</li>";
							}
							sHtml += "</ul>";
							$("div#fastDiv").append(sHtml);
							$("div#fastDiv").show();
							$("span#fastTxt").hide();
						}else{
							$("span#fastTxt").text("빠른 예약 일정이 없습니다.");
							$("div#fastDiv").hide();
							$("span#fastTxt").show();
						}
					}else{
						$("span#fastTxt").text("빠른 예약 일정이 없습니다.");
						$("div#fastDiv").hide();
						$("span#fastTxt").show();
					}
				},
				error:function(request,status,error){
					alert("처리 중 오류가 발생되었습니다.\nerror:"+error+"request:"+request+"status:"+status);
					$("div#fastDiv").hide();
					$("span#fastTxt").show();
				}
			});
		}
		
		function fn_ActionFastSchedule(centcd,orddeptnm,resvDd,resvHh){
			//var selDeptNm = $("#selDeptNm").val();
			if( centcd != "-" ){
				$("#emrCenterCd").val(centcd);
				//selDeptNm = orddeptnm;
			}
			//$("#selDeptNm").val(selDeptNm);
			$("#emrCenterCd").val(centcd);
			$("#resvDd").val(resvDd);
			$("#schDate").val($("#resvDd").val().substring(8, 11));
			$("#resvHh").val(resvHh);
			fn_Step("4");
		}
	</script>

	<style>
    #section1 {position: relative; z-index: 9;}
	::-webkit-scrollbar { width: 10px; }
	::-webkit-scrollbar-thumb { background: #000; }
	</style>
</head>
<body class="group_main">
<form id="frm" name="frm" method="POST">
	<input type="hidden" id="sitePath" name="sitePath" value="home">
	<input type="hidden" id="resvIdx" name="resvIdx" value="">
	<input type="hidden" id="hspCd" name="hspCd" value="G">
	<input type="hidden" id="memYn" name="memYn" value="Y">
	<!-- 예약자 정보 -->
	<input type="hidden" id="userId" name="userId" value="<%=member.getUserId() %>">
	<input type="hidden" id="userType" name="userType" value="<%=member.getUserStat() %>">
	<input type="hidden" id="resvType" name="resvType" value="me">
	<input type="hidden" id="userNm" name="userNm" value="<%=member.getUserNm() %>">
	<input type="hidden" id="gender" name="gender" value="<%=member.getSex() %>">
	<input type="hidden" id="ptNo" name="ptNo" value="00151083">
	<input type="hidden" id="userBirthDt" name="userBirthDt" value="<%=member.getBirthDt() %>">
	<input type="hidden" id="phone" name="phone" value="<%=member.getTelNo() %>">
	<input type="hidden" id="zipCd" name="zipCd" value="<%=member.getZipCd() %>">
	<input type="hidden" id="addr" name="addr" value="<%=member.getAddr() %>">
	<input type="hidden" id="detlAddr" name="detlAddr" value="<%=member.getDetlAddr() %>">
	<!--  진협 예약시 추가되는 파라메타  -->
	<input type="hidden" id="ssnNo1" name="ssnNo1" value="">
	<input type="hidden" id="ssnNo2" name="ssnNo2" value="">
	<input type="hidden" id="Corporal" name="Corporal" value="KgnvCRVnparT97RfdPjf/m9uYNZ7ZXrqcoa2pFwxXwg=">
	<input type="hidden" id="memo" name="memo" value="KgnvCRVnparT97RfdPjf/m9uYNZ7ZXrqcoa2pFwxXwg=">
	<input type="hidden" id="returnContYN" name="returnContYN" value="">
	<input type="hidden" id="refer_resvYN" name="refer_resvYN" value="N">
	<input type="hidden" id="resv_flag" name="resv_flag" value="HOME">
	<!-- 진료과 정보 -->
	<input type="hidden" id="selDeptNo" name="selDeptNo" value="80">
	<input type="hidden" id="selDeptCd" name="selDeptCd" value="2011000000">
	<input type="hidden" id="selDeptNm" name="selDeptNm" value="감염내과">
	<input type="hidden" id="emrDeptCd" name="emrDeptCd" value="2011000000">
	<input type="hidden" id="emrCenterCd" name="emrCenterCd">
	<!-- 의료진 정보 -->
	<input type="hidden" id="selProfNo" name="selProfNo" value="989">
	<input type="hidden" id="selEmpNo" name="selEmpNo" value="01419">
	<input type="hidden" id="selProfNm" name="selProfNm" value="정혜민">
	<input type="hidden" id="selProfUuidNm" name="selProfUuidNm" value="ff52944c-bb52-43d9-9b2c-6434103abe26">
	<input type="hidden" id="emrProfCd" name="emrProfCd" value="01419">
	<input type="hidden" id="resvAdultYn" name="resvAdultYn" value="A">
	<!-- 시간 정보 -->
	<input type="hidden" id="schYear" name="schYear" value="2023">
	<input type="hidden" id="schMonth" name="schMonth" value="12">
	<input type="hidden" id="schDate" name="schDate" value="">
	<input type="hidden" id="resvDd" name="resvDd" value="">
	<input type="hidden" id="resvHh" name="resvHh" value="">
   <!-- 진료예약 -->
   <div class="reservation_wrap">
       <div class="inner">
           <div class="reservation_header">
               <h1 class="tit">온라인 예약</h1>
               <a href="#" class="btn_close"><span class="skip">닫기</span></a>
           </div>
           <div class="reservation_content">

               <!-- 환자정보 -->
               <div class="patient_wrap">
                   <p class="p_name">강민채</p>
                   <p class="p_num">환자번호 <span>00151083</span></p>

                   <div class="dec_list_wrap">
                       <dl>
                           <dt class="">연락처</dt>
                           <dd class="p_phone" id="phoneDt">010-5502-0745</dd>
                       </dl>
                       <dl>
                           <dt>생년월일</dt>
                           <dd class="p_birth">
								2001-06-09
							</dd>
                       </dl>
                       <!-- 안 쓰기로 했던 거 
                       <dl>
                           <dt>최근진료일</dt>
                           <dd class="p_c_date"><span class="empty_txt">최근진료일이 없습니다.</span></dd>
                       </dl>
                       -->
                   </div>

               </div>
               <!-- // 환자정보 -->

               <!-- 예약 항목-->
               <div class="content_wrap">
                   <!-- 진료시간 선택 -->
                   <div class="time_sec">

                       <div class="header_tit_area">
                           <div class="tit_area fix">
                               <dl class="state_now">
                                   <dt>STEP 03</dt>
                                   <dd class="tit">진료시간 선택</dd>
                               </dl>

                               <dl class="step_next">
                                   <dt>&nbsp;</dt>
                                   <dd class="tit">예약완료</dd>
                               </dl>
                           </div>

                           <div class="sec_tit_area fix">
                               <p class="tit"><span>진료일정</span></p>
                           </div>

                       </div>

                       <div class="info_area" style="display:block;">
                           <div class="con_header_wrap fix">
                               <div class="lft_con">
                                   <p class="doctor_img">
                                   	
										
										
											<img src="/_upload/profImg/ff52944c-bb52-43d9-9b2c-6434103abe26" alt="정혜민 교수">
										
										
									
                                   </p>
                                   <p class="doctor_tit"><strong>정혜민 교수</strong> 진료일정입니다.</p>
                               </div>
                               <div class="rgt_con">
                                   <ul class="index_info_wrap sty2">
                                       <li class="ico_today">오늘</li>
                                       <li class="ico_available">예약 가능 날짜</li>
                                       <li class="ico_select">선택</li>
                                   </ul>
                               </div>
                           </div>
                          
                           		
                           			
                           			
                           		
                           
                           <div class="timetable_wrap fix">
                               <div id="calendarForm" class="sel_cal">
                                   <ul id="calendar_ul" class="cal_top fix">
                                   	   <li><a href="javascript:void(0);" class="prev" onclick="javascript:fn_MonthSearch('2023', '11');"><span class="skip">이전달</span></a></li>
                                       <li>2023-12</li>
                                       <li><a href="javascript:void(0);" class="next" onclick="javascript:fn_MonthSearch('2023', '13');"><span class="skip">다음달</span></a></li>
                                   </ul>
                                   <div class="cal_cont">
                                       <table id="calendar_table" class="">
                                           <colgroup>
                                               <col style="width: calc(100%/ 7);">
                                               <col style="width: calc(100%/ 7);">
                                               <col style="width: calc(100%/ 7);">
                                               <col style="width: calc(100%/ 7);">
                                               <col style="width: calc(100%/ 7);">
                                               <col style="width: calc(100%/ 7);">
                                               <col style="width: calc(100%/ 7);">
                                           </colgroup>
                                           <thead>
                                               <tr>
                                                   <th>일</th>
                                                   <th>월</th>
                                                   <th>화</th>
                                                   <th>수</th>
                                                   <th>목</th>
                                                   <th>금</th>
                                                   <th>토</th>
                                               </tr>
                                           </thead>
                                           <tbody id="custom_set_date">
                                           	   	
							                	
							                	
							                		
						                			<tr><td>
						                				
						                					
									                			
						                					
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
									                			
						                					
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
									                			
						                					
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
									                			
						                					
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
									                			
						                					
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
									                			
									                				<a href="javascript:void(0);" class="" style="cursor: auto;">
										                			01
										                			
										                			</a>
									                			
						                					
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
									                			
									                				<a href="javascript:void(0);" class="" style="cursor: auto;">
										                			02
										                			
										                			</a>
									                			
						                					
						                					
						                				
						                			</td>
							                		
							                			</tr>
							                			
							                		
							                	
							                		
						                			<tr><td>
						                				
						                					
									                			
									                				<a href="javascript:void(0);" class="" style="cursor: auto;">
										                			03
										                			
										                			</a>
									                			
						                					
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
									                			
									                				<a href="javascript:void(0);" class="" style="cursor: auto;">
										                			04
										                			
										                			</a>
									                			
						                					
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
									                			
									                				<a href="javascript:void(0);" class="" style="cursor: auto;">
										                			05
										                			
										                			</a>
									                			
						                					
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
									                			
									                				<a href="javascript:void(0);" class="" style="cursor: auto;">
										                			06
										                			
										                			</a>
									                			
						                					
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
									                			
									                				<a href="javascript:void(0);" class="cal_today" style="cursor: auto;">
										                			07
										                			
										                			</a>
									                			
						                					
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:fn_selDate('08');" class="schDay sel_possible" style="">
										                			08
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:void(0);" class="schDay" style="cursor: auto;">
										                			09
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                			</tr>
							                			
							                		
							                	
							                		
						                			<tr><td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:void(0);" class="schDay" style="cursor: auto;">
										                			10
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:void(0);" class="schDay" style="cursor: auto;">
										                			11
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:void(0);" class="schDay" style="cursor: auto;">
										                			12
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:fn_selDate('13');" class="schDay sel_possible" style="">
										                			13
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:fn_selDate('14');" class="schDay sel_possible" style="">
										                			14
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:fn_selDate('15');" class="schDay sel_possible" style="">
										                			15
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:fn_selDate('16');" class="schDay sel_possible" style="">
										                			16
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                			</tr>
							                			
							                		
							                	
							                		
						                			<tr><td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:void(0);" class="schDay" style="cursor: auto;">
										                			17
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:void(0);" class="schDay" style="cursor: auto;">
										                			18
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:void(0);" class="schDay" style="cursor: auto;">
										                			19
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:fn_selDate('20');" class="schDay sel_possible" style="">
										                			20
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:fn_selDate('21');" class="schDay sel_possible" style="">
										                			21
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:void(0);" class="schDay" style="cursor: auto;">
										                			22
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:void(0);" class="schDay" style="cursor: auto;">
										                			23
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                			</tr>
							                			
							                		
							                	
							                		
						                			<tr><td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:void(0);" class="schDay" style="cursor: auto;">
										                			24
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:void(0);" class="schDay" style="cursor: auto;">
										                			25
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:void(0);" class="schDay" style="cursor: auto;">
										                			26
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:fn_selDate('27');" class="schDay sel_possible" style="">
										                			27
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:fn_selDate('28');" class="schDay sel_possible" style="">
										                			28
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:fn_selDate('29');" class="schDay sel_possible" style="">
										                			29
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:void(0);" class="schDay" style="cursor: auto;">
										                			30
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                			</tr>
							                			
							                		
							                	
							                		
						                			<tr><td>
						                				
						                					
						                					
									                			
									                				<a href="javascript:void(0);" class="schDay" style="cursor: auto;">
										                			31
										                			
										                			</a>
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
						                					
						                				
						                			</td>
							                		
							                	
							                		
						                			<td>
						                				
						                					
						                					
									                			
						                					
						                				
						                			</td>
							                		
							                			</tr>
							                			
							                		
							                	
                                           </tbody>
                                       </table>
                                   </div>
								</div>
								<div class="sel_time">
									
								</div>
                           </div>
                       </div>
                   </div>
                   <!-- // 진료시간 선택 -->
					
					
					
						<div class="quick_reserv_wrap">
							<div class="quick_reserv_tit">
								<a href="javascript:void(0);" class="btn_quick_list" onclick="javascript:fn_SearchFastSchedule();"><span>빠른일정조회</span></a>
							</div>
							<div class="quick_reserv_con">
								<div id="fastDiv" style="display: block;"><ul class="quick_reserv_list"><li>[감염내과] 2023-12-08 08:30<a href="javascript:void(0);" class="btn_quick_reserv" onclick="javascript:fn_ActionFastSchedule('-','감염내과','2023-12-08','08:30');"><span>예약하기</span></a></li></ul></div>
								<span id="fastTxt" class="txt" style="display: none;">빠른 예약 일정을 조회하시려면 '빠른일정조회' 버튼을 클릭해 주세요.</span>
							</div>
						</div>
					
               </div>
               <!-- // 예약 항목-->

               <!-- 예약결과 -->
               <div class="result_wrap">
                   <p class="tit">예약하실 정보 확인</p>

                   <div class="dec_list_wrap">
                       <dl>
                           <dt>진료과</dt>
                           <dd class="c_dept">
                           		<span>감염내과</span>
                           </dd>
                       </dl>
                       <dl>
                           <dt>의료진</dt>
                           <dd class="c_doctor">
                           		<span>정혜민</span>
                           </dd>
                       </dl>
                       <dl>
                           <dt>진료일시</dt>
                           <dd class="c_date" id="selTime">
								<span class="empty_txt">선택된 진료일시가 없습니다.</span>
                           </dd>
                       </dl>
                   </div>

                   <!-- 진행현황 -->
                   <ol class="result_state_sec">
                       <li><em>01</em> 진료과 선택</li>
                       <li><em>02</em> 의료진 선택</li>
                       <li class="on"><em>03</em> 진료시간 선택</li>
                   </ol>
                   <!-- // 진행현황 -->
               </div>
               <!-- // 예약결과 -->

               <!-- 버튼 -->
               <div class="reservation_btn_wrap fix">
                   <a href="javascript:void(0);" class="btn_step_prev btnClose" onclick="javascript:fn_Step(2);"><span>이전</span></a>
                   <a href="javascript:void(0);" class="btn_step_next" onclick="javascript:fn_Step(4);"><span>예약확정</span></a>
               </div>
               <!-- // 버튼 -->

           </div>
       </div>
   </div>
   <!-- //진료예약 -->

   <style>
		/* reservation.css 추가 */
		.reservation_popup_wrap .popup_content .box_tit{padding: 12px 0;font-size: 17px;line-height: 1.5;font-weight: 700;border-radius: 5px 5px 0 0;background: #001b52;margin-top: 20px;color: #fff;}
		.reservation_popup_wrap .popup_content textarea{border: 1px solid #f4f5f9;border-radius: 0 0 5px 5px;margin: 0;width: 100%;padding: 24px;resize:none;height: 100px;font-family: 'Noto Sans Korean';font-size: 14px;font-weight: 400;line-height: 1.5;background: #f4f5f9;}
		.reservation_popup_wrap .popup_content textarea::placeholder{font-size:14px; color:#333;}
	</style>

   <!-- 예약확인 팝업 -->
	<div class="reservation_popup_wrap" style="display:none;" id="resvConfirm">
		<div class="popup_dim"></div>
		<div class="popup_inner">
			<div class="popup_header"></div>
			<div class="popup_content">
				<div class="con_txt">강민채님<em class="m_block"></em>
					<strong id="strTime"></strong><em class="m_block"></em>
                   	<strong>감염내과 정혜민 교수님</strong>께<em class="m_block"></em>진료예약 하시겠습니까?
               	</div>
               	<div class="con_txt">
					<p class="box_tit">주요 증상</p>
					
						
						
							<textarea class="input_text" id="symMemo" name="symMemo" maxlength="300" placeholder="주요 증상을 작성해주시기 바랍니다." title="증상입력"></textarea>
						
					
				</div>
			</div>
           	<div class="btn_area">
				<a href="javascript:void(0);" onclick="javascript:fn_Step(5);" class="btn_pop_sty1"><span>예약확정</span></a>
               	<a href="javascript:void(0);" class="btn_pop_sty0 popClose"><span>다시선택</span></a>
           	</div>
		</div>
	</div>
	<!-- // 예약확인 팝업 -->

	<!-- 18세 확인 팝업 -->
	<div class="reservation_popup_wrap" style="display:none;" id="adultConfirm">
		<div class="popup_dim"></div>
		<div class="popup_inner">
			<div class="popup_header"></div>
			<div class="popup_content">
				<div class="con_txt">강민채님<em class="m_block"></em>
					<strong id="strTime"></strong><em class="m_block"></em>
					
						
						
						
						
						
					
				</div>
			</div>
			<div class="btn_area">
				<!-- <a href="javascript:void(0);" onclick="javascript:fn_Step(5);" class="btn_pop_sty1"><span>예약확정</span></a> -->
				<a href="javascript:void(0);" class="btn_pop_sty1 popUpClose"><span>확인</span></a>
			</div>
		</div>
	</div>
	<!-- // 18세 예약확인 팝업 -->
</form>
</body></html>