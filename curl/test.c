#include <curl/curl.h>

int main()
{
    curl_global_init(CURL_GLOBAL_NOTHING);

    CURL *curl = curl_easy_init();

    curl_easy_setopt(curl, CURLOPT_URL, "http://planaris.skriblovsky.net/download.php");

    FILE *f = fopen("tmp", "wb");
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, f);


    CURLcode res = curl_easy_perform(curl);

    printf("%d\n", res);

    fclose(f);
    curl_easy_cleanup(curl);

    return 0;
}
