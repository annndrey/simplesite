## -*- coding: utf-8 -*-
<%inherit file="lietlahti:templates/template_base.mak"/>

<script src="//tinymce.cachefly.net/4.2/tinymce.min.js"></script>
<script src="${req.static_url('lietlahti:static/js/injectText.js')}" type='text/javascript'></script>

<script type="text/javascript">
 tinymce.init(
     {selector:'textarea#inputArticle',
      plugins: "code link image",
      toolbar: "insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image upload",
      setup: function(editor) {
          editor.addButton('upload', {
              text: 'Upload',
              icon: false,
              onclick: function() {
                  ##editor.insertContent('uploaded content');
                  ##tinymce.get("uploadModal").show();
                  $("#uploadModal" ).modal('show');//.show();
              }
          });
      }
     });
</script>

<script type="text/javascript">
 function changeposttype(){
     
     if($("#posttype option:selected").text() == 'Исходный код'){
         //tinymce.execCommand('mceToggleEditor',true,'new-post-desc');
         tinymce.EditorManager.execCommand('mceRemoveEditor',true, 'inputArticle');
     }else{
         tinymce.EditorManager.execCommand('mceAddEditor',true, 'inputArticle');
     }
 }
</script>

<script type="text/javascript">
 $(document).ready(function(){
     $("#inputSeries").select2({
     /*width:'240px',*/
         allowClear:true,
         formatNoMatches: function(term) {
             /* customize the no matches output */
             return "<input class='form-control' id='newTerm' value='"+term+"'><a href='#' id='addNew' class='btn btn-default'>Создать</a>"
         }
     })
                      .parent().find('.select2-with-searchbox').on('click','#addNew',function(){
                          /* add the new term */
                          var newTerm = $('#newTerm').val();
                          //alert('adding:'+newTerm);
                          $('<option>'+newTerm+'</option>').appendTo('#inputSeries');
                          $('#inputSeries').select2('val',newTerm); 
                          $("#inputSeries").select2('close');
                      })
 });
</script>

<div class="inner"> 
    % if session_message and session_message[0]=='edited':
	<div class="alert alert-success" role="alert">Публикация сохранена! <a href="${request.route_url('article', url=article.url)}">Посмотреть</a></div>
    % endif
    <div class="col-md-offset-1">
        % if not edit:
	    <form role="form" method="post" action="${req.route_url('newarticle')}">
        % else:  
            <form role="form" method="post" action="${req.route_url('edit', pub='article', id=article.id)}">
        % endif

                <div class="row">
	            <div class="col-md-10 col-md-offset-1 col-sm-10 col-sm-offset-1" align='justify'>
	                <div class="form-group">
	                    <label for="inputMainname" class="col-md-2 control-label">Название</label>
	                    <div class="col-md-10">
	                        <input type="text" class="form-control" id="inputMainname" name="inputMainname" placeholder="Название" 
		                       % if edit:
		                       value="${article.mainname}"
		                       % endif
		                >
	                    </div>
	                </div>
	            </div>
                </div>
                
                <div class="row">
	            <div class="col-md-10 col-md-offset-1 col-sm-10 col-sm-offset-1" align='justify'>
	                <div class="form-group">
	                    <label for="inputKeywords" class="col-md-2 control-label">Ключевые слова</label>
	                    <div class="col-md-10">
	                        <input type="text" class="form-control" id="inputKeywords" name="inputKeywords" placeholder="новая статья, путешествия, приключения"
		                       % if edit:
		                       value="${article.keywords}"
		                       % endif
		                >
		                <select class="form-control" id="inputStatus" name="inputStatus">
		                    % for s in article_status.keys():
			                % if edit:
			                    % if s == article.status:
			                        <option selected value="${s}">${article_status[s]}</option>
			                    % else:
			                        <option value="${s}">${article_status[s]}</option>
			                    % endif
			                % else:
			                    % if s == 'draft':
			                        <option selected value="${s}">${article_status[s]}</option>
			                    % else:
			                        <option value="${s}">${article_status[s]}</option>
			                    % endif
			                % endif   
		                    % endfor
		                </select>
	                    </div>
	                </div>
	            </div>
                </div>
        
                <div class="row">
	            <div class="col-md-10 col-md-offset-1 col-sm-10 col-sm-offset-1" align='justify'>
	                <div class="form-group">
	                    <label for="inputSeries" class="col-md-2 control-label">Серия статей</label>
	                    <div class="col-md-10">
	                        <select class="form-control" id="inputSeries" name="inputSeries">
		                    % if article_series is not None:
		                        % for s in article_series:
		                            % if edit:
		                                % if s == article.series:
			                            <option selected value="${s}">${s}</option>
                                                % else:
                                                    <option value="${s}">${s}</option>
                                                % endif  
		                            % else:
		                                <option value="${s}">${s}</option>
		                            % endif   
		                        % endfor
		                    % endif
	                        </select>
	                        
	                    </div>
	                </div>
	            </div>
                </div>
        ##      <div class="row">
        ##	<div class="col-md-10 col-md-offset-1 col-sm-10 col-sm-offset-1" align='justify'>
        ##	  <div class="form-group">
        ##	    <label for="inputSeries" class="col-md-2 control-label">Координаты, Lat/Lon</label>
        ##	    <div class="col-md-3">
        ##	      <input type="text" class="form-control" id="lat" name="lat" placeholder='Lattitude'
        ##		     % if edit:
        ##		       % if article.lat is not None:
        ##			 value="${article.lat}"
        ##		       % endif
        ##		     % endif
        ##		     >
        ##	    </div>
        ##	    <div class="col-md-3">
        ##	      <input type="text" class="form-control" id="lon" name="lon" placeholder='Longitude'
        ##		     % if edit:
        ##		       % if article.lon is not None:
        ##			 value="${article.lon}"
        ##		       % endif
        ##		     % endif
        ##		     >
        ##	    </div>
        ##	  </div>
        ##	</div>
        ##    </div>
                <div class="row">
	            <div class="col-md-10 col-md-offset-1 col-sm-10 col-sm-offset-1" align='justify'>
	                <div class="form-group">
	                    <label for="inputDescr" class="col-md-2 control-label">Описание</label>
	                    <div class="col-md-10">
	                        <input type="text" class="form-control" id="inputDescr" name="inputDescr" placeholder="Описание"
		                       % if edit:
		                       value="${article.descr}"
		                       % endif
		                >
	                    </div>
	                </div>
	                
	                <div class="form-group">
	                    <label for="inputURL" class="col-md-2 control-label">URL страницы</label>
	                    <div class="col-md-10">
	                        <input type="text" class="form-control" id="inputURL" name="inputURL" placeholder="yourarticleurl"
		                       % if edit:
		                       value="${article.url}"
		                       % endif
		                >
	                    </div>
	                </div>
                        
                ##	  <div class="form-group">
                ##	    <label for="inputLeftBracket" class="col-md-2 control-label">Оформление</label>
                ##	    <div class="col-xs-3">
                ##	      <input type="text" class="form-control" id="inputLeftBracket" name="inputLeftBracket" placeholder="левая скобка"
                ##		     % if edit:
                ##		       value="${article.left_bracket_url}"
                ##		     % endif
                ##		     >
                ##	    </div>
                ##
                ##	    <div class="col-xs-3">
                ##	      <input type="text" class="form-control" id="inputRightBracket" name="inputRightBracket" placeholder="правая скобка"
                ##		     % if edit:
                ##		       value="${article.right_bracket_url}"
                ##		     % endif
                ##		     >
                ##	    </div>
                
                
                ##	    <div class="col-xs-4">
                ##	      <input type="text" class="form-control" id="inputSep" name="inputSep" placeholder="разделитель"
                ##		     % if edit:
                ##		       value="${article.sep_url}"
                ##		     % endif
                ##		     >
                ##	    </div>
                ##	  </div>
                
                ##	  <div class="form-group">
                ##	    <label for="inputPrevPict" class="col-md-2 control-label">Заглавная картинка</label>
                ##	    <div class="col-md-10">
                ##	      <input type="text" class="form-control" id="inputPrevPict" name="inputPrevPict" placeholder="заглавная картинка"
                ##		     % if edit:
                ##		       % if article.previewpict is not None:
                ##			 value="${article.previewpict}"
                ##		       % endif
                ##		     % endif
                ##		     >
                ##	    </div>
                ##	  </div>
	        
                
	            </div>
                </div>
        
                <div class="row">
	            <div class="col-md-10 col-md-offset-1 col-sm-10 col-sm-offset-1" align='justify'>
	                
	                <div class="col-md-12">
	                    % if edit:
	                        % if article.previewtext is not None:
		                    <textarea class="form-control" id="inputPrevText" name="inputPrevText" placeholder="Краткий текст для превью" rows=3>${article.previewtext|n}</textarea>
	                        % else:
		                    <textarea class="form-control" id="inputPrevText" name="inputPrevText" placeholder="Краткий текст для превью" rows=3></textarea>
	                        % endif
	                    % else:
	                        <textarea class="form-control" id="inputPrevText" name="inputPrevText" placeholder="Краткий текст для превью" rows=3></textarea>
	                    % endif
	                    
                            <select id="posttype" class="form-control" onchange="changeposttype()">
                                <option>Визуальный редактор</option>
                                <option>Исходный код</option>
                            </select>
                            
	                    % if edit:
     	                        <textarea class="form-control" id="inputArticle" name="inputArticle" placeholder="Основной текст" rows=20>${article.maintext|n}</textarea>
	                    % else:
	                        <textarea class="form-control" id="inputArticle" name="inputArticle" placeholder="Основной текст" rows=20></textarea>
	                    % endif
	            
	                    <input type="hidden" id="csrf" name="csrf" value="${req.session.get_csrf_token()}" />
                            <a data-toggle="modal" data-target="#uploadModal" class="btn btn-default pull-right">Загрузить файл</a>
	                    <a href="${req.referrer}" type="button" class="btn btn-default pull-right">Отменить</a>
	                    <button type="submit" class="btn btn-default pull-right" id="submit" name="submit" title="Опубликовать" tabindex="3">Сохранить</button>
	                </div>
	            </div>
                </div>

                
    	    </form>
            <div class="modal fade" id="uploadModal" tabindex="-1" role="dialog" aria-labelledby="uploadModal" aria-hidden="true">
  	        <div class="modal-dialog">
    	            <div class="modal-content">
      	                <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                            <h4 class="modal-title" id="uploadModal">Загрузить что-нибудь</h4>
      	                </div>
      	                <div class="modal-body">
                            <form class="form-inline" enctype="multipart/form-data" id="fileupload" name="fileupload" role="form" method="post" action="#">
		                <div class="form-group">
		                    <input type="file" name="file" size=60>
		                </div>
		                <div class="form-group">
		                    <input type='checkbox' name='preserve' value='preserve'>Сохранить навсегда!!
		                </div>
		                <div class="form-group">
		                    <input type="hidden" id="csrf" name="csrf" value="${req.session.get_csrf_token()}" />
		                </div>
      		                <div class="modal-footer">
		                    <button type="button" class="btn btn-default" data-dismiss="modal">Закрыть</button>
		                    <button type="submit" class="btn btn-primary">Загрузить</button>
		                </div>
	                    </form>
	                </div>
	            </div>
	        </div>
            </div>
    </div>  
    

    </div>
</div>



