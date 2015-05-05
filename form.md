---
layout: page
title: SAMIT download
---

# Download registration form

It is helpful for us to know about the potential users of the toolbox. Therefore, we ask you to complete a registration form before downloading SAMIT.

* Please, supply at least your name, institution and location.
* This information is used for demographic purposes only.
* Your email address **will not** be added to any list, unless specified otherwise.
* Any additional comments are will be emailed directly to the developers of the toolbox.
* Submitting the form will take you to the page with the latest version of the SAMIT software.

<form action="http://formspree.io/samit@umcg.nl" method="POST">
  <input type="hidden" name="_subject" value="SAMIT: New form" />
  <input type="hidden" name="_cc" value="d.vallez-garcia@umcg.nl" />
  <input type="hidden" name="_next" value="{{ site.baseurl }}/download" />
  <input type="text" name="_gotcha" style="display:none" />
  <p>
  First name:  <input type="text" name="firstname"> <br>
  Last name:   <input type="text" name="lastname"> <br>
  Institution: <input type="text" name="institute"> <br>
  Country:     <input type="text" name="country"> <br>
  e-mail:      <input type="email" name="_replyto"> <br>
  </p>
  
  <p>
  Do you want to be including in a mail-list for updates?<br>
  <input type="radio" name="mail-list" value="Yes">Yes<br>
  <input type="radio" name="mail-list" value="No" checked>No<br>
  </p>
  
  <p>
  Enter any additional comments below...<br>
  <textarea name="body" rows="6" cols="150">
  </textarea>
  </p>
  
  <input type="reset" value="Clear form">
  <input type="submit" value="Send form">

</form>
