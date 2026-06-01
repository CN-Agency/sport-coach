import { useEffect } from 'react';

const SITE_NAME = 'Home Workout';
const BASE_URL = 'https://sport.cn-agency.fr';

interface SeoOptions {
  /** Page title (without the site name suffix). */
  title: string;
  /** Meta description for this page. */
  description?: string;
  /** Canonical path, e.g. "/exercises". Defaults to the current pathname. */
  path?: string;
}

function setMeta(attr: 'name' | 'property', key: string, content: string) {
  let el = document.head.querySelector<HTMLMetaElement>(`meta[${attr}="${key}"]`);
  if (!el) {
    el = document.createElement('meta');
    el.setAttribute(attr, key);
    document.head.appendChild(el);
  }
  el.setAttribute('content', content);
}

function setCanonical(href: string) {
  let el = document.head.querySelector<HTMLLinkElement>('link[rel="canonical"]');
  if (!el) {
    el = document.createElement('link');
    el.setAttribute('rel', 'canonical');
    document.head.appendChild(el);
  }
  el.setAttribute('href', href);
}

/**
 * Updates document title, meta description, canonical and Open Graph tags for
 * the current route. Needed because this is a client-rendered SPA — without it
 * every route would share the static tags from index.html.
 */
export function useSeo({ title, description, path }: SeoOptions) {
  useEffect(() => {
    const fullTitle = `${title} — ${SITE_NAME}`;
    const canonical = `${BASE_URL}${path ?? window.location.pathname}`;

    document.title = fullTitle;
    setMeta('property', 'og:title', fullTitle);
    setMeta('name', 'twitter:title', fullTitle);
    setMeta('property', 'og:url', canonical);
    setCanonical(canonical);

    if (description) {
      setMeta('name', 'description', description);
      setMeta('property', 'og:description', description);
      setMeta('name', 'twitter:description', description);
    }
  }, [title, description, path]);
}
