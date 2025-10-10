import requests
import json
import argparse
from typing import List, Dict

def search_hcl_support(search_query: str, cookies: Dict[str, str], user_token: str) -> List[Dict]:
    """
    Search HCL Support using their internal API
    
    Args:
        search_query: The search term
        cookies: Dictionary of cookies from your browser session
        user_token: X-UserToken from your browser session
    
    Returns:
        List of search results with title, KB number, date, views, etc.
    """
    
    url = "https://support.hcl-software.com/api/now/uxf/databroker/exec"
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:143.0) Gecko/20100101 Firefox/143.0',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'en-US,en;q=0.7,de-DE;q=0.3',
        'Content-Type': 'application/json;charset=utf-8',
        'X-UserToken': user_token,
        'X-Transaction-Source': 'Interface=Web,Interface-Name=CSM,Interface-Type=Service Portal,Interface-SysID=89275a53cb13020000f8d856634c9c51',
        'X-Use-Polaris': 'false',
        'Origin': 'https://support.hcl-software.com',
        'Referer': f'https://support.hcl-software.com/csm?id=search&spa=1&q={search_query}',
    }
    
    # Format search query - wrap in quotes if it contains spaces
    formatted_query = f'"{search_query}"' if ' ' in search_query else search_query
    
    # API payload
    payload = [{
        "definitionSysId": "0cac8b3073ad101052c7d5fdbdf6a78a",
        "type": "GRAPHQL",
        "inputValues": {
            "paginationToken": {"type": "JSON_LITERAL", "value": None},
            "searchEvamConfigId": {"type": "JSON_LITERAL", "value": "e17bc2432ba522105e6bfc7ffe91bf7b"},
            "searchTerm": {"type": "JSON_LITERAL", "value": formatted_query},
            "facetFilters": {"type": "JSON_LITERAL", "value": None},
            "sortOptions": {"type": "JSON_LITERAL", "value": '["714652032be522105e6bfc7ffe91bf10"]'},
            "vaEvamDefinitionId": {"type": "JSON_LITERAL", "value": "b224e17e530020103296ddeeff7b123f"},
            "disableSpellCheck": {"type": "JSON_LITERAL", "value": "false"},
            "asyncParams": {"type": "JSON_LITERAL", "value": '{asyncMode: "GR_ONLY", callbackType: "AMB", enableStreaming: "true"}'},
            "searchFilters": {"type": "JSON_LITERAL", "value": '["4cf41e8f2ba522105e6bfc7ffe91bf38"]'},
            "searchPurview": {"type": "JSON_LITERAL", "value": "ALL"},
            "additionalContext": {"type": "JSON_LITERAL", "value": '{"citationVersion":"2","streaming": {"context": {"skipNoAnswerResponse": "true"}},"request_origin":{"origin":"portal","name":"csm"} , "queryConversationalCatalog":"false"}'},
            "searchContextConfigId": {"type": "JSON_LITERAL", "value": "f5e41e8f2ba522105e6bfc7ffe91bfb8"}
        }
    }]
    
    # Make the request
    print(f"Searching for: '{search_query}'")
    response = requests.post(url, headers=headers, cookies=cookies, json=payload)
    response.raise_for_status()
    
    # Parse response
    data = response.json()
    
    # Check what search term the API actually used
    actual_search_term = data['result'][0]['executionResult']['searchMetadata']['searchResultMetadata']['searchTerm']
    total_hits = data['result'][0]['executionResult']['searchMetadata']['searchResultMetadata']['totalHits']
    print(f"API searched for: '{actual_search_term}'")
    print(f"Total hits: {total_hits}")
    print()
    
    # Extract search results
    results = []
    try:
        items = data['result'][0]['executionResult']['searchResultsTemplates']['items']
        
        for item in items:
            prop_values = item.get('propValues', {})
            model = prop_values.get('model', {})
            
            result = {
                'kb_number': prop_values.get('textHeaderLabelTwo', 'N/A'),
                'title': prop_values.get('title', 'N/A'),
                'category': prop_values.get('detailValueFour', 'N/A'),
                'document_type': prop_values.get('textHeaderLabelThree', 'N/A'),
                'created_date': model.get('sys_created_on', 'N/A'),
                'updated_date': model.get('sys_updated_on', 'N/A'),
                'summary': prop_values.get('summary', 'N/A'),
                'sys_id': model.get('sys_id', 'N/A'),
                'url': f"https://support.hcl-software.com/csm?id=kb_article&sysparm_article={prop_values.get('textHeaderLabelTwo', '')}"
            }
            results.append(result)
            
    except (KeyError, IndexError) as e:
        print(f"Error parsing response: {e}")
        print(f"Response data: {json.dumps(data, indent=2)[:500]}")
    
    return results


def print_results(results: List[Dict]):
    """Pretty print search results"""
    print(f"\n{'='*80}")
    print(f"Found {len(results)} results")
    print(f"{'='*80}\n")
    
    for i, result in enumerate(results, 1):
        print(f"{i}. {result['title']}")
        print(f"   KB Number: {result['kb_number']}")
        print(f"   Type: {result['document_type']} | Category: {result['category']}")
        print(f"   Created: {result['created_date']} | Updated: {result['updated_date']}")
        print(f"   URL: {result['url']}")
        print()


if __name__ == "__main__":
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Search HCL Support knowledge base')
    parser.add_argument('search_term', help='Search term (e.g., "8.0 CR12" or Stöttner)')
    parser.add_argument('--headless', action='store_true', help='Run in headless mode (no output files)')
    args = parser.parse_args()
    
    # IMPORTANT: Update these values from your browser session
    # To get these:
    # 1. Open browser DevTools (F12)
    # 2. Go to Network tab
    # 3. Perform a search on the HCL site
    # 4. Find the request to /api/now/uxf/databroker/exec
    # 5. Copy the Cookie header and X-UserToken header values
    
    COOKIES = {
        'JSESSIONID': '7B1B543756D1A3C2CCCCA433F31177D6',  # UPDATE THIS
        'glide_user_route': 'glide.d9e874240f68b1c4211ad5d8816cc8ae',  # UPDATE THIS
        'glide_sso_id': '55dfb2b41b78da9c534c4159cc4bcb66',  # UPDATE THIS
        # Add other cookies as needed
    }
    
    USER_TOKEN = '07624a7c3bac3a94cb0155f726e45ac8de1293f6a687572a6418cb4bba3697454b5be9d8'  # UPDATE THIS
    
    try:
        results = search_hcl_support(args.search_term, COOKIES, USER_TOKEN)
        
        if results:
            print_results(results)
            
            if not args.headless:
                # Save to JSON file
                filename = f'hcl_search_results_{args.search_term.replace(" ", "_")}.json'
                with open(filename, 'w', encoding='utf-8') as f:
                    json.dump(results, f, indent=2, ensure_ascii=False)
                print(f"✓ Results saved to '{filename}'")
        else:
            print("No results found or error parsing response")
            
    except requests.exceptions.HTTPError as e:
        print(f"HTTP Error: {e}")
        print("Your session tokens may have expired. Please update COOKIES and USER_TOKEN.")
    except Exception as e:
        print(f"Error: {e}")
