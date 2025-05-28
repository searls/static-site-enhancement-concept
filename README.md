# A mechanism for enhancing static sites with server-side-ish dynamic behavior

I've been maintaining [justin.searls.co](https://justin.searls.co) as a static site since 2020 as a [Hugo](https://gohugo.io) site. While I generally love hosting a bunch of static files without any real server costs (thanks to [Netlify](https://www.netlify.com)'s generous free tier), there are times where I really want just a _wee_ bit of dynamic behavior.

So, thanks to GitHub Actions, I've added that dynamic behavior like sprinkles on top of the sundae. They run on a cron schedule (every X minutes) and after each push to the default branch.

Here's the files in this repo as of 5/28/2025. I'll update them if anything mind-blowing happens in the future. This'll give you an idea of where the bodies are buried:

```
.
├── .github
│   └── workflows
│       └── enhance.yml
├── .gitignore
├── config
│   └── enhancements.yml
├── Gemfile
├── Gemfile.lock
├── README.md
└── script
    ├── enhance_content
    ├── ext
    │   └── time.rb
    └── lib
        ├── cli.rb
        ├── commands
        │   ├── add_cards_to_takes.rb
        │   ├── advance_publication_date.rb
        │   └── update_publish_date_cache.rb
        ├── content.rb
        ├── de_bug.rb
        ├── enhancement_config.rb
        ├── quoted_string.rb
        └── scan.rb
```


So I've got a single script `script/enhance_content` that is run by a GitHub action in `.github/workflows/enhance.yml` and which uses `config/enhancements.yml` as a sort of scratch pad for maintaining state.

Right now the enhance script does three things:

1. Loads all my recently-edited content files and updates a cache of their publication dates in `config/enhancements.yml`
2. Generates social previews for all the URLs referenced in my site's [takes](https://justin.searls.co/takes) section where an `og:image` can be found in the linked document by updating the take with the title and image URL (yes, I'm just hotlinking people's images, YOLO)
3. If any content files had a future-dated publication date (i.e. `date:` in the YAML frontmatter) and that date is now in the past, update the `config/enhancements.yml`. This will push a git commit to the repo and, in turn, trigger a Netlify build

The third one is basically a poor man's auto-publisher, which is something I've wanted for my static sites forever, and for which the ongoing cost of running and maintaining a live content management system simply hasn't been worth it.

Anyway, if you're in the same business, maybe this repo will give you some good (bad) ideas.
