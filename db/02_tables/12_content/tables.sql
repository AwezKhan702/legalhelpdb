-- Legal awareness / CMS content (FSD §25)

CREATE TABLE content.articles (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    slug            text NOT NULL UNIQUE,
    title           text NOT NULL,
    body            text NOT NULL,
    language_code   text NOT NULL DEFAULT 'en' REFERENCES catalog.languages (code),
    category_id     uuid REFERENCES catalog.service_categories (id),
    is_published    boolean NOT NULL DEFAULT false,
    published_at    timestamptz,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER articles_set_updated_at
    BEFORE UPDATE ON content.articles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
