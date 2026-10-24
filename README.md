# LJT-Homepage

Personal academic website for **Junteng Liu**, forked from [Academic Pages](https://github.com/academicpages/academicpages.github.io).

## Content

- The existing **About** page contains the biography, academic background, scholarship, research experience, research areas and interests, all six publications, and contact information.
- The existing **Publications** page renders the same six records from `_data/publications.yml` using `_includes/publication-list.html`.
- No additional content pages are created. Template posts, collection entries, demonstration pages, images, and sample downloads are excluded from the generated site.
- Biographical and publication content comes only from the supplied memory. The recorded wording “first-year” and dates ending in “Present” are preserved. No programming-language/tool proficiencies, portrait, or paper/code URLs are invented.
- The profile's GitHub link remains `Vicent0205` as supplied in memory; the hosting repository is `spaldingpitzenur80-ops/LJT-Homepage`.

## Build and validate

```sh
bundle install
JEKYLL_ENV=production bundle exec jekyll build --strict_front_matter
bundle exec ruby scripts/validate_site.rb
```

For a local preview, run `bundle exec jekyll serve` and open `http://localhost:4000/LJT-Homepage/`.

## GitHub Pages

The project path is configured as:

- `url: https://spaldingpitzenur80-ops.github.io`
- `baseurl: /LJT-Homepage`

The **Build and deploy LJT-Homepage** workflow builds and validates the site on pushes to `master` and supports manual runs. Deployment runs only when **Settings → Pages → Build and deployment → Source** is set to **GitHub Actions**. If Actions are disabled for the fork, they must also be enabled in the repository's Actions tab.

Once Pages is enabled and deployment succeeds, the site URL is `https://spaldingpitzenur80-ops.github.io/LJT-Homepage/`.
