## -*- coding: utf-8 -*-

<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta name="keywords" content="lietlahti discuss page" />
        <meta name="description" content="lietlahti" />
        <meta name="google-site-verification" content="KCm6wt6-vBwRhC5OXitcWJoZpm-nS6OAp7GqC_tPBl0" />
        <title>${_('Лиетлахти, природно-этнографический парк')}</title>

 
        <link rel="stylesheet" href="${req.static_url('lietlahti:static/css/bootstrap.css')}" type="text/css" />
        <link rel="stylesheet" href="${req.static_url('lietlahti:static/css/colorbox.css')}" type="text/css" />
        <link rel="stylesheet" href="${req.static_url('lietlahti:static/css/select2.css')}" type="text/css" />
        <link rel="stylesheet" href="${req.static_url('lietlahti:static/css/select2-bootstrap.css')}" type="text/css" />
        ##<link rel="stylesheet" href="${req.static_url('lietlahti:static/css/bootstrap-glyphicons.css')}" type="text/css" />
        ##<link rel="stylesheet" href="${req.static_url('lietlahti:static/css/font-awesome.css')}" type="text/css" />
        <link rel="stylesheet" href="${req.static_url('lietlahti:static/css/social-likes_birman.css')}" type="text/css" />
        <link rel="stylesheet" href="${req.static_url('lietlahti:static/css/main.css')}" type="text/css" />
       
        <link rel="icon" type="image/png" href="${req.static_url('lietlahti:static/favicon.png')}" />
        <script type="text/javascript" src="${req.static_url('lietlahti:static/js/jquery.js')}"></script>
        <script type="text/javascript" src="${req.static_url('lietlahti:static/js/jquery.actual.js')}"></script>
        <script type="text/javascript" src="${req.static_url('lietlahti:static/js/bootstrap.js')}"></script>
        <script type="text/javascript" src="${req.static_url('lietlahti:static/js/jquery.photoset-grid.js')}"></script>
        <script type="text/javascript" src="${req.static_url('lietlahti:static/js/jquery.colorbox.js')}"></script>
        <script type="text/javascript" src="${req.static_url('lietlahti:static/js/fileupload.js')}"></script>
        <script type="text/javascript" src="${req.static_url('lietlahti:static/js/select2.js')}"></script>
        <script type="text/javascript" src="${req.static_url('lietlahti:static/js/jquery.scrollorama.js')}"></script>
        <script type="text/javascript" src="${req.static_url('lietlahti:static/js/social-likes.min.js')}"></script>
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
        <script type="text/javascript">
         $(document).ready(function() {
             $('select#lang').on('change', function() {
                 var lang = $(this).val();
                 window.location = "/language"+'?lang='+lang+"&ret="+"${req.path_qs}";
             });
         });
        </script>
    </head>
    

    <body>
        <div id="wrap">
            <div class="container">
                <div class="btn-group btn-group-justified" role="group">
                    <a class="btn btn-default btn-sm" role="button" href="tel:${contacts.get('phone')}"><img width=15px src="${req.static_url('lietlahti:static/icons/phone.png')}"></span> <span class="hidden-xs hidden-sm">${contacts.get('phone')}</span></a>
                    <a class="btn btn-default btn-sm" href="mailto:${contacts.get('email')}" role="button"><img width=15px src="${req.static_url('lietlahti:static/icons/mail.png')}"> <span class="hidden-xs hidden-sm">${contacts.get('email')}</span></a> 
                    <a class="btn btn-default btn-sm" href="${contacts.get('vk')}" role="button"><img width=15px src="${req.static_url('lietlahti:static/icons/vk.png')}"> <span class="hidden-xs hidden-sm">${contacts.get('vk').replace('https://', '')}</span></a>
                    <a class="btn btn-default btn-sm" href="${contacts.get('fb')}" role="button"><img width=15px src="${req.static_url('lietlahti:static/icons/fb.png')}"> <span class="hidden-xs hidden-sm">${contacts.get('fb').replace('https://', '')}</span></a>
                    <a class="btn btn-default btn-sm" href="${contacts.get('instagramm')}" role="button"><img width=15px src="${req.static_url('lietlahti:static/icons/instagramm.png')}"> <span class="hidden-xs hidden-sm">${contacts.get('instagramm').replace('http://', '')}</span></a>
                </div>
                <nav  class="navbar navbar-default" role="navigation">
                    % if pagename:
                        <a class="navbar-brand"><p><img alt="Brand" width=20px src="${req.static_url('lietlahti:static/favicon.png')}"> ${pagename | n}</p></a>
                    % else:
                        <a class="navbar-brand"><p><img alt="Brand" width=20px src="${req.static_url('lietlahti:static/favicon.png')}"> ${pagename }</p></a>
                    % endif
                    <div class="container-fluid">
                        <p class="navbar-text navbar-right">
                            % if auth:
                                ${_('Здравствуйте')}, ${authuser}! 
	                        <a data-toggle="tooltip" data-placement="top" title=${_("Выйти")} href="${request.route_url('logout')}"><span class="glyphicon glyphicon-log-out"></span></a>
	                    % else:
	                        % if request.current_route_url() != request.route_url('login'):
	                            <a href="${request.route_url('login')}">${_('Вход')} <span class="glyphicon glyphicon-log-in"></a>
	                        % endif  
	                    % endif
                            
	                    <ul class="nav navbar-nav">
                                ##
	                    % if request.current_route_url() != request.route_url('main'):
	                        <li><a href="${request.route_url('main')}">${_('Главная')}</a></li>
	                    % endif
                  
                            % if articles:
                                % for a in articles:
                                    % if a.series == 'mainpage':
                                        % if article:
                                            % if article.id != a.id:
                                                <li><a href="${request.route_url('article', url=a.url)}">${a.getvalue("mainname", lang)}</a></li>
                                            % endif 
                                        % else:
                                            <li><a href="${request.route_url('article', url=a.url)}">${a.getvalue("mainname", lang)}</a></li>
                                        % endif
                                    % endif
                                % endfor
                            % endif  
                  
	                    % if auth:
	                        % if not 'discuss' in request.current_route_url():
		                    <li><a href="${request.route_url('home')}" title='${_("Чатик")}'><span class="glyphicon glyphicon-comment"></span></a></li>
	                        % else:
		                    ## put a link here
		                    ##<li><a href="#" role="button" class="btn popovers" data-toggle="popover" title="Popover title" data-content="And here's some amazing content. It's very engaging. Right?"></a></li>
		                    <li>
                                        <a href="#" role="button" class="btn popovers" data-toggle="popover" title="" data-content="${"<br>".join("{0}: <a href='{3}#{2}'>{1}</a>".format(p.name, p.post, p.id, request.route_url("article", url=p.page)) for p in newcomments)}" data-original-title="${_("Новые комментарии")}" data-placement="bottom"> ${_('новые комментарии')} <span class="badge">${str(newcomments.count())}</span></a></li>
	                        % endif
	                        % if request.current_route_url() != request.route_url('newarticle'):
		                    <li><a href="${request.route_url('newarticle')}" title="${_("Новая публикация")}"><span class="glyphicon glyphicon-pencil"></span></a></li>
	                        % endif
	                    % endif
                            <li>
                                <select id='lang' class="btn btn-default btn-sm" style="margin-top:10px">
                                    % if lang and lang == 'en': 
                                        <option>ru</option>
                                        <option selected>en</option>
                                    % else:
                                        <option selected>ru</option>
                                        <option>en</option>
                                    % endif
                                </select>
                            </li>
	                    </ul>
	                </p>
                    </div>
                </nav>
                ${next.body()}
                

                <div id="push"></div>
            </div>
            
            <div id="footer">
                <div class="container">
                    <div id='flag' class='pull-right'><img src="http://pomoyka.homelinux.net/immortal/522ba11d-c22c-4e87-b296-8d229624a90a.jpg" width=50px></div>
                    <p class="muted credit">Copyright &copy; Lietlahti Park, <script type="text/javascript">
                                                                         var d = new Date()
                                                                             document.write(d.getFullYear())
                    </script> <a href="https://github.com/annndrey"><img src="${req.static_url('lietlahti:static/favicon.png')}" width=20px></a>
                    </p>

                </div>
            </div>
        </div>
        <script>
         (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
             (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
                                  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
         })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
         
         ga('create', 'UA-69339047-1', 'auto');
         ga('send', 'pageview');
         
        </script>
    </body>
</html>
