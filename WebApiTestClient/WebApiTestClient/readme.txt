-------------------
Web API Test Client 
-------------------
A simple Test Client built on top of ASP.NET Web API Help Page.

Upon installation, the package will automatically attempt to inject 
the following test client code into Areas\HelpPage\Views\Help\Api.cshtml
	@Html.DisplayForModel("TestClientDialogs")
	@Html.DisplayForModel("TestClientReferences")
That's it. No additional setup required when it's completed successfully.