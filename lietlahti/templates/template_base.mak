<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" xmlns:tal="http://xml.zope.org/namespaces/tal">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge;chrome=1" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="keywords" content="lietlahti discuss page" />
    <meta name="description" content="lietlahti" />
    <title>¡LIETLAHTI!</title>
    
    <link rel="stylesheet" href="${req.static_url('lietlahti:static/css/main.css')}" type="text/css" />
    <link rel="stylesheet" href="${req.static_url('lietlahti:static/css/bootstrap.css')}" type="text/css" />
    <link rel="stylesheet" href="${req.static_url('lietlahti:static/css/colorbox.css')}" type="text/css" />
    <link rel="stylesheet" href="${req.static_url('lietlahti:static/css/select2.css')}" type="text/css" />
    <link rel="stylesheet" href="${req.static_url('lietlahti:static/css/select2-bootstrap.css')}" type="text/css" />
    <link rel="stylesheet" href="${req.static_url('lietlahti:static/css/bootstrap-glyphicons.css')}" type="text/css" />
    <link rel="stylesheet" href="${req.static_url('lietlahti:static/css/font-awesome.css')}" type="text/css" />
    ##<link rel="stylesheet" href="${req.static_url('lietlahti:static/css/leaflet.css')}" type="text/css" />
    
    <script type="text/javascript" src="${req.static_url('lietlahti:static/js/jquery.js')}"></script>
    <script type="text/javascript" src="${req.static_url('lietlahti:static/js/jquery.actual.js')}"></script>
    <script type="text/javascript" src="${req.static_url('lietlahti:static/js/bootstrap.js')}"></script>
    <script type="text/javascript" src="${req.static_url('lietlahti:static/js/jquery.photoset-grid.js')}"></script>
    <script type="text/javascript" src="${req.static_url('lietlahti:static/js/jquery.colorbox.js')}"></script>
    <script type="text/javascript" src="${req.static_url('lietlahti:static/js/fileupload.js')}"></script>
    <script type="text/javascript" src="${req.static_url('lietlahti:static/js/select2.js')}"></script>
    <script type="text/javascript" src="${req.static_url('lietlahti:static/js/leaflet.js')}"></script>

    <script type="text/javascript" src="https://www.google.com/recaptcha/api.js" async defer></script>
    <script type="text/javascript">
    $(document).ready(function() {
      $('.popovers').popover({container: 'body', html: true});
    });    
    </script>

    <script type="text/javascript">
     $(window).load( function() {
       $('.photoset-grid-lightbox').photosetGrid({
	 highresLinks: true,
	 lowresWidth: 400,
	 rel: 'withhearts-gallery',
	 gutter: '2px',
	 onComplete: function(){
	   $('.photoset-grid-lightbox').attr('style', '');
	   $('.photoset-grid-lightbox a').colorbox({
	     photo: true,
	     scalePhotos: true,
	     minWidth:'1%',
	     maxHeight:'90%',
	     maxWidth:'90%'
	   });
	 }
       });
     });
    </script>
    
 </head>
  <body>
    ## set navbar here
<div id="wrap">
  <div class="container">
    
    <nav class="navbar navbar-default" role="navigation">
      <a class="navbar-brand">${pagename}</a>
      <div class="container-fluid">
	<p class="navbar-text navbar-right">
  	  % if auth:
	    Здравствуйте, ${authuser}! 
	    <a data-toggle="tooltip" data-placement="top" title="Выйти" href="${request.route_url('logout')}"><span class="glyphicon glyphicon-log-out"></span></a>
	  % else:
	    % if request.current_route_url() != request.route_url('login'):
	      Вход <a href="${request.route_url('login')}"><span class="glyphicon glyphicon-log-in"></a>
	    % endif  
	  % endif
	  <ul class="nav navbar-nav">
            ##
	    % if request.current_route_url() != request.route_url('main'):
	      <li><a href="${request.route_url('main')}">Главная</a></li>
	    % endif
	    % if auth:
	      % if not 'discuss' in request.current_route_url():
		<li><a href="${request.route_url('home')}" title="Чатик"><span class="glyphicon glyphicon-comment"></span></a></li>
	      % else:
		## put a link here
		##<li><a href="#" role="button" class="btn popovers" data-toggle="popover" title="Popover title" data-content="And here's some amazing content. It's very engaging. Right?"></a></li>
		<li><a href="#" role="button" class="btn popovers" data-toggle="popover" title="" data-content="${"<br>".join(["В <a href={3}>{0}</a>  {1} написал: {2} ".format(p.article.mainname, p.name, p.post, request.route_url('article', url=p.page)) for p in newcomments]) }"  data-original-title="Новые комментарии" data-placement="bottom"> новые комментарии <span class="badge">${str(newcomments.count())}</span></a></li>
	      % endif
	      % if request.current_route_url() != request.route_url('newarticle'):
		<li><a href="${request.route_url('newarticle')}" title="Новая публикация"><span class="glyphicon glyphicon-pencil"></span></a></li>
	      % endif
	    % endif
	  </ul>
	   ##<form class="navbar-form " role="search">
	   ## <div class="input-group col-sm-3 col-md-3 col-lg-3">
           ##   <input type="text" size=14 class="form-control" placeholder="Искать" name="srch-term" id="srch-term">
           ##   <div class="input-group-btn">
	   ##	<button class="btn btn-default disabled" type="submit"><i class="glyphicon glyphicon-search"></i></button>
           ##   </div>
           ## </div>
	   ##</form>

	</p>
      </div>
    </nav>
    ${next.body()}
    <div id="push"></div>
  </div>
  <div id="footer">
    <div class="container">
      <p class="muted credit">LIETLAHTI, 2015, <a href="https://github.com/annndrey"><img src="http://pomoyka.homelinux.net/immortal/10fbbd32-7ad5-4872-b928-5f15c900e2be.png" width=20px></a></p>
    </div>
  </div>
</div>
  </body>
</html>
