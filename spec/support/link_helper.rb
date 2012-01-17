
module LinkHelper

  def link_for(links, rel)

    rel = rel == 'self' ? /^self$/ : /#{rel}$/

    (links.find { |l| l['rel'].match(rel) } || {})['href']
  end
end

