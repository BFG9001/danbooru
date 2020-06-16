module ArtistCommentariesHelper
  def format_commentary_title(title, classes: "")
    tag.h3 do
      tag.span(class: "prose #{classes}") do
        format_text(title, disable_mentions: true, inline: true)
      end
    end
  end

  def format_commentary_description(description, classes: "")
    _mSVdesuArchiveRefPattern = />>\d+\s/ #Whitespace at the end of expression to ensure already-linked post references don't get parsed
    descriptionX = description + " " #account for an edge case where >>##### references at the EOF do not get counted because they lack a whitespace.
    descriptionX.scan(_mSVdesuArchiveRefPattern).each do |postRef|
      postRef = postRef[0..-2] #remove the whitespace from the regular expression. 
      rawPostNumber = postRef[2..-1]
      modifiedText = "\"" + postRef + "\"" ":[https://desuarchive.org/m/post/" + rawPostNumber + "]"
      description.gsub!(postRef, modifiedText)
      puts(description)
    end
    #The above is to automatically parse and hotlink ">>#######" post numbers from 4chan.org/m/ and turn them into links to desu archive. The actual linking is done by DText.

    tag.div(class: "prose #{classes}") do
      format_text(description, disable_mentions: true)
    end
  end
end
