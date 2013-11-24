<script type="text/javascript">
	$(function() {
		$( "#tabs" ).tabs();
	});
	$('#sendgrid-info').css('display','none');
    $('#sendgrid').change(function(){
        if(document.getElementById('sendgrid').value == 1){
            $('#sendgrid-info').show('slow');    
        } else 
            if(document.getElementById('sendgrid').value == 0){
             $('#sendgrid-info').hide('slow'); 
        }
    });
    $('#sengrid').change();
</script>
<br><br>
<div align="center">
	<div id="tabs" style="width:95%;">
		<ul>
			<li><a href="#tabs-1">General</a></li>
			<li><a href="#tabs-2">Mail</a></li>
			<li><a href="#tabs-3">Bandwidth</a></li>
			<li><a href="#tabs-4">Templates</a></li>
		</ul>
		<form id="form2" name="form2" method="post" action="">
			<div id="tabs-1">
				<p>
					<div class="st-form-line">	
						<span class="st-labeltext">Title: </span>
						<input name="title" type="text" class="st-forminput" id="title" style="width:510px" value="" /> 
						<div class="clear"></div>
					</div>
					<div class="st-form-line">	
						<span class="st-labeltext">Description: </span>
						<input name="description" type="text" class="st-forminput" id="description" style="width:510px" value="" /> 
						<div class="clear"></div>
					</div>
					<div class="st-form-line">	
						<span class="st-labeltext">Panel URL (without http://): </span>
						<input name="panel_url" type="text" class="st-forminput" id="panel_url" style="width:510px" value="" /> 
						<div class="clear"></div>
					</div>
					<div class="st-form-line">	
						<span class="st-labeltext">Maintenance Mode: </span>
						<label class="margin-right10"><input type="checkbox" name="maintanance" value="1" id="maintanance" class="uniform"/> Enabled</label>
						<div class="clear"></div>
					</div>
					<div class="st-form-line">	
						<span class="st-labeltext">Update Branch:</span>
						<select name="update_type" id="update_type" class="uniform">
							<option value="develop">Development</option>
							<option value="develop-develop">Testing (not recommended)</option>
						</select>
						<div class="clear"></div>
					</div>
				</p>
			</div>
			<div id="tabs-2">
				<p>
					<div class="st-form-line">	
						<span class="st-labeltext">Mail Sender Type:</span>
						<select name="sendgrid" id="sendgrid" class="uniform">
							<option value="0" {%if isset|sendgrid == false}selected="selected"{%/if}>Sendmail</option>
							<option value="1" {%if isset|sendgrid == true}{%if empty|sendgrid == true}selected="selected"{%/if}{%/if}>Send Grid</option>
						</select>
						<div class="clear"></div>
					</div>
					<div id="sendgrid-info">
						<div class="st-form-line">	
							<span class="st-labeltext">Sendgrid Username: </span>
							<input name="sendgrid_username" type="text" class="st-forminput" id="sendgrid_username" style="width:510px" value="" /> 
							<div class="clear"></div>
						</div>
						<div class="st-form-line">	
							<span class="st-labeltext">Sendgrid Password: </span>
							<input name="sendgrid_password" type="password" class="st-forminput" {%if isset|sendgrid_password == true}value="password"{%/if} id="sendgrid_password" style="width:510px" value="" /> 
							<div class="clear"></div>
						</div>
					</div>
				</p>
			</div>
			<div id="tabs-3">
				<p></p>
			</div>
			<div id="tabs-4">
				<p></p>
			</div>
		</form>
	</div>
</div>