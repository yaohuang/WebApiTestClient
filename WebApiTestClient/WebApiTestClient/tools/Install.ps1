param($installPath, $toolsPath, $package, $project)
$file = $project.ProjectItems.Item("Areas").ProjectItems.Item("HelpPage").ProjectItems.Item("Views").ProjectItems.Item("Help").ProjectItems.Item("Api.cshtml")
if($file) {
    $file.Open()
    $file.Document.Activate()
    $file.Document.Selection.StartOfDocument()
	if(!$file.Document.MarkText("@Html.DisplayForModel(`"TestClientDialogs`")"))
	{
		$file.Document.ReplaceText("@model HelpPageApiModel", "@model HelpPageApiModel`n@section Scripts {`n    @Html.DisplayForModel(`"TestClientDialogs`")`n    @Html.DisplayForModel(`"TestClientReferences`")`n}")
		$file.Save()
	}
	else
	{
		$file.Document.ClearBookmarks()
	}
}