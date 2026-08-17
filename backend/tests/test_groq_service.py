import pytest
from app.services.groq_service import GroqService, GroqServiceException


def test_extract_json_block():
    # 1. Plain JSON
    raw = '{"hooks": ["a", "b"]}'
    assert GroqService._extract_json_block(raw) == '{"hooks": ["a", "b"]}'

    # 2. Markdown fenced JSON
    fenced = '```json\n{"hooks": ["a", "b"]}\n```'
    assert GroqService._extract_json_block(fenced) == '{"hooks": ["a", "b"]}'

    # 3. Preamble + JSON + Postscript
    preamble = 'Here is the JSON you requested:\n{"hooks": ["a", "b"]}\nHope this helps!'
    assert GroqService._extract_json_block(preamble) == '{"hooks": ["a", "b"]}'
