## -*- coding: utf-8 -*-
<%inherit file="lietlahti:templates/template_base.mak"/>

<script src="//tinymce.cachefly.net/4.2/tinymce.min.js"></script>
<script src="${req.static_url('lietlahti:static/js/injectText.js')}" type='text/javascript'></script>

<script type="text/javascript">
 tinymce.init(
     {selector:"textarea[id^='inputArticle_']",
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
         tinymce.EditorManager.execCommand('mceRemoveEditor',true, 'inputArticle_ru');
         tinymce.EditorManager.execCommand('mceRemoveEditor',true, 'inputArticle_en');
     }else{
         tinymce.EditorManager.execCommand('mceAddEditor',true, 'inputArticle_ru');
         tinymce.EditorManager.execCommand('mceAddEditor',true, 'inputArticle_en');
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

	% for lng in alllang:
            <div class="row">
	        <div class="col-md-10 col-md-offset-1 col-sm-10 col-sm-offset-1" align='justify'>
	            <div class="form-group">
                        
                        <label for="${"inputMainname_"+lng}" class="col-md-2 control-label">Название (${lng})</label>
	                <div class="col-md-5">
	                    <input type="text" class="form-control" id=${"inputMainname_"+lng} name=${"inputMainname_"+lng} placeholder="Название (${lng})" 
		                   % if edit:
		                   value="${article.getvalue("mainname", lng)}"
		                   % endif
                                   
		            >
	                </div>
	            </div>
	        </div>
            </div>
        % endfor        
        <br><br>
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
	            </div>
	        </div>
	    </div>
        </div>
        <br><br>
        <div class="row">
	    <div class="col-md-10 col-md-offset-1 col-sm-10 col-sm-offset-1" align='justify'>
	        <div class="form-group">
                    <label for="inputStatus" class="col-md-2 control-label">Статус</label>
                    <div class="col-md-10">
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
        <br><br>
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
        <br><br>
        <div class="row">
	    <div class="col-md-10 col-md-offset-1 col-sm-10 col-sm-offset-1" align='justify'>
	        ##<div class="form-group">
	        ##    <label for="inputDescr" class="col-md-2 control-label">Описание</label>
	        ##    <div class="col-md-10">
	        ##        <input type="text" class="form-control" id="inputDescr" name="inputDescr" placeholder="Описание"
		##               % if edit:
		##               value="${article.descr}"
		##               % endif
		##        >
	        ##    </div>
	        ##</div>
	        
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
	    </div>
        </div>
        <br><br>
        <div class="row">
	    <div class="col-md-10 col-md-offset-1 col-sm-10 col-sm-offset-1" align='justify'>
	        
	        <div class="col-md-12">
                    % for lng in alllang:
	                % if edit:
	                    % if article.getvalue("previewtext", lng) is not None:
		                <textarea class="form-control" id=${"inputPrevText_"+lng} name=${"inputPrevText_"+lng} placeholder="Краткий текст для превью (${lng})" rows=3>${article.getvalue("previewtext", lng)|n}</textarea>
	                    % else:
		                <textarea class="form-control" id=${"inputPrevText_"+lng} name=${"inputPrevText_"+lng} placeholder="Краткий текст для превью (${lng})" rows=3></textarea>
	                    % endif
                            
	                % else:
	                    <textarea class="form-control" id=${"inputPrevText_"+lng} name=${"inputPrevText_"+lng} placeholder="Краткий текст для превью (${lng})" rows=3></textarea>
	                % endif
                    % endfor	                    
                    <select id="posttype" class="form-control" onchange="changeposttype()">
                        <option>Визуальный редактор</option>
                        <option>Исходный код</option>
                    </select>
                    % for lng in alllang:
	                % if edit:
                            % if article.getvalue("maintext", lng) is not None: 
     	                        <textarea class="form-control" id=${"inputArticle_"+lng} name=${"inputArticle_"+lng} placeholder="Основной текст (${lng})" rows=20>${article.getvalue("maintext", lng)|n}</textarea>
                                <br><br>
                            % else:
                                <textarea class="form-control" id=${"inputArticle_"+lng} name=${"inputArticle_"+lng} placeholder="Основной текст (${lng})" rows=20>Основной текст (${lng})</textarea>
                                <br><br>
                            % endif
	                % else:
	                    <textarea class="form-control" id=${"inputArticle_"+lng} name=${"inputArticle_"+lng} placeholder="Основной текст (${lng})" rows=20>Основной текст (${lng})</textarea>
                            <br><br>
	                % endif
	            % endfor
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



